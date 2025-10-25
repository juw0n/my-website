### **Introduction**
Two years ago, I started a simple project to explore Infrastructure as Code (IaC) using Terraform. I recently revisited it with a fresh perspective — not just to complete it, but to dive deeper into managing existing cloud resources with IaC. What sparked this? I noticed that many people skip the backend IaC part of the Cloud Resume Challenge, and I wanted to change that.

Revisiting a simple project i did about two years ago, first to implement an idea and research i did on managing an existing project with IAC, Terraform in my case, also to complete the project because i think and from reasearch most people dont actually do the backend IAC part of the project, my conclusion from limited resources online.

It is an online challenge called [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/). it is a hands-on cloud engineering project that helps you build a real-world, serverless web application using any of the cloud providers (AWS, Azure or GCP), I use AWS. It’s more than just a static site, it connects front-end, back-end, CI/CD and Infrastructure as Code concepts into one project not leaving out security.

With the abundance of documentations and resources available online, I’ll walk you through a high level of how I designed and deployed my Cloud Resume Challenge project using AWS, GitHub Actions and Terraform, with a clean, scalable architecture.

### ** 🧱 Project Overview**
Here’s what the project does:

**__PS:__** To begin, you need to own/have a domain name (i.e human-friendly address of a website). I recommend using Namecheap, a reliable and user-friendly domain registrar or you use anyone you are familiar with.

* Hosts a personal resume website.
* Displays a visitor counter powered by AWS Lambda and DynamoDB.
* Uses a CI/CD pipeline for automated testing and deployment.
* Secures the site with HTTPS via AWS Certificate Manager.

The high-level architecture looks like this:

![Project Architecture Diagram](https://github.com/juw0n/my-website/blob/main/AWS%20Resume%20Achitecture.jpg)

### **🔧 Core AWS Components**
1. Amazon S3 (Static Website Hosting)
    * I created and uploaded the website file to an S3 bucket.
    * I disable public access to the file and enable on HTTPS for security which will be delivered with cloudfront.

2. AWS CloudFront (Content Delivery Network)
    * CloudFront serves the S3 website contents securely over HTTPS, providing low-latency access for global visitors.
    * It uses an SSL/TLS certificate from AWS Certificate Manager for HTTPS.
3. AWS Certificate Manager (SSL)
    * I requested a free SSL/TLS certificate for my domain to enable HTTPS.
    * The certificate is associated with the CloudFront distribution.
    * This ensures visitors always access my resume over HTTPS.
4. AWS Route 53 (Domain Management)
    * I configured Route 53 to manage my domain's DNS settings.
    * Created an alias record pointing my domain to the CloudFront distribution.
    * It routes user traffic to CloudFront through a custom domain.
5. AWS Lambda + DynamoDB (Visitor Counter)
    * DynamoDB stores the visitor count in a scalable NoSQL table.
    * I developed a Lambda function (a small Python script) to retrieve and increment the visitor count from DynamoDB.
    * The function is triggered via Lambda function URL when the website loads.
This setup keeps the backend serverless, meaning no EC2 instances to manage!

### **🔄 CI/CD Pipeline with GitHub Actions**
To automate testing and deployment, I set up a CI/CD pipeline using GitHub Actions:
1. On every push to the main branch, GitHub Actions triggers a workflow.
2. The workflow runs tests to ensure website integrity.
3. If tests pass, the workflow deploys the updated website files to the S3 bucket
4. This automation ensures that any changes to the website are quickly and reliably deployed.

### **📦 Infrastructure as Code with Terraform**
To manage the AWS infrastructure, I used Terraform to define and provision resources. This is the part where i want to share some things that i learnt new. 
Following the challenge instructions, you will most likely use ***ClickOps method*** to create all your resources and almost have the site working at the point you get to the where you will be told to use as IaC tools. 
I found out that defining and creating the resources in terraform file means i will have to recreate all the resources again and by that point, my visitor counter had already recorded over 500 views and it got me thinking what if this is a live project that is not been manage by an IaC and i want to start managing them through IaC. that is the point where i got to learn and use **__Terraform import__** command.

### **🧠 What is terraform import?**
The `terraform import` command is used to bring existing resources, which were not originally created or managed by Terraform, under Terraform's management,  allowing you to manage the lifecycle of these resources using Terraform configurations and state, aslo known as Infrastructure as Code.
The syntax for the command is as follows:
```
terraform import [options] ADDRESS ID
```
**ADDR** – a valid resources address (e.g. aws_instance.instance_name)
**ID** – A resource unique identifier in the cloud provider, which is dependent on the resource type being imported. (e.g arn value of aws resoures)

These are some basic information about the resouces to be imported and they can be gotten from the resource page in your account.

Here is an example of how i defined and imported the DynamoDB table resource in my terraform file.
In `main.tf` file:
```
resource "aws_dynamodb_table" "cloudResumeViewsTable" {
  name           = "cloudResumeViewsTable"
  billing_mode   = "unknown"
  read_capacity  = "unknown"
  write_capacity = "unknown"
  hash_key       = "unknown"

  attribute {
    name = "id"
    type = "S"
  }
}
```

```
terraform import aws_dynamodb_table.cloudResumeViewsTable arn:aws:dynamodb:us-east-1:357078656374:table/cloudResumeViewsTable
```

The terraform import command only imports the resource into the Terraform state file; it does not automatically generate the corresponding configuration in the `.tf` file, also the resources block must exist in the `.tf` file for the resources to be imported.

After importing the resources and terraform.tfstate file gets populated, I updated the resources definition block with information from the tfstate file.

Not all of the attributes are currently reflected in `.tf` configuration. Since we haven't changed the values of its characteristics, any attempt to apply or implement this configuration would fail. Hence. run the `Terraform plan` and look at the results to bridge the gap between the configuration and state files.

It's critical to realize that the terraform.tfstate file is an essential reference Terraform. It takes this state file into consideration when performing any subsequent operations. To ensure that there is as little to no difference as possible between them, you must examine the state file and modify your configuration appropriately, which means on every modification you run `terraform plan` to see the changes that will be made.
**`PS:`** To reach a state of zero difference, you must further align your resource block with the state file. 
### **Conclusion**
After successfully importing all the resources used in the project, I can now manage them using Terraform going forward. Any future changes to the infrastructure can be made by updating the Terraform configuration files and applying those changes using `terraform apply`.

### **Resources**
* [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/)
* [Terraform Import Documentation](https://developer.hashicorp.com/terraform/cli/commands/import
)
