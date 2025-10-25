### **Introduction**
Two years ago, I started a simple project to explore Infrastructure as Code (IaC) using Terraform. I recently revisited it with a fresh perspective, not just to complete it, but to dive deeper into managing existing cloud resources with IaC. What sparked this? I noticed that most of us skip the backend IaC part of the [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/), and I wanted to change that.

 This challenge is a hands-on cloud engineering project that helps you build a real-world, serverless web application using AWS, Azure, or GCP. I chose AWS, I use AWS. It’s more than just a static site, it connects front-end, back-end, CI/CD and IaC concepts into one project not leaving out security.

With the abundance of documentations and resources available online, I’ll walk you through a high level of how I designed and deployed my Cloud Resume Challenge project using AWS, GitHub Actions and Terraform, with a clean, scalable architecture.

### ** 🧱 Project Overview**
Here’s what the project does:

**__PS:__** To begin, you need to own/have a domain name (i.e, a human-friendly address of a website). I recommend Namecheap for its simplicity, but any registrar works, an account with any cloud service provider and a user with programmatic access credentials.

* Hosts a personal resume website.
* Displays a visitor counter powered by AWS Lambda and DynamoDB.
* Uses a CI/CD pipeline for automated testing and deployment.
* Secures the site with HTTPS via AWS Certificate Manager.

The high-level architecture looks like this:

![Project Architecture Diagram](https://github.com/juw0n/my-website/blob/main/AWS%20Resume%20Achitecture.jpg)

### **🔧 Core AWS Components**
1. Amazon S3 (Static Website Hosting)
    * I created and uploaded the website file to an S3 bucket.
    * Public access was disabled, and HTTPS was enabled for secure access via cloudfront.

2. AWS CloudFront (Content Delivery Network)
    * CloudFront serves the S3 website contents securely over HTTPS.
    * It uses an SSL/TLS certificate from AWS Certificate Manager.
3. AWS Certificate Manager (SSL)
    * I requested a free SSL/TLS certificate for my domain.
    * The certificate is attached to the CloudFront distribution.
    * This ensures visitors always access my resume over HTTPS.
4. AWS Route 53 (Domain Management)
    * I configured Route 53 to manage my domain's DNS linked with namecheap.
    * Created an alias record pointing my domain to the CloudFront distribution.
5. AWS Lambda + DynamoDB (Visitor Counter)
    * DynamoDB stores the visitor count.
    * I developed a Lambda function (a small Python script) to retrieve and increment the visitor count from DynamoDB.
    * The function is triggered via Lambda function URL when the website loads.
This setup keeps the backend serverless, meaning no EC2 instances to manage!

### **🔄 CI/CD Pipeline with GitHub Actions**
To automate testing and deployment, I set up a CI/CD pipeline using GitHub Actions:
1. On every push to the main branch, GitHub Actions triggers two workflows.
2. one updated website files to the S3 bucket.
3. the second runs tests to ensure the Lambda function works, if tests pass, the workflow deploys the infrastrusture with terraform.

This automation ensures that any change is deployed quickly and reliably.

### **📦 Infrastructure as Code with Terraform**
Here’s where things got interesting.
Following the challenge instructions, you will most likely use ***ClickOps method*** to create all your resources and almost have the site working at the point you get to the where you will be told to use as IaC tools. 
But when I reached the IaC part, I realized I’d have to recreate everything in Terraform, even though my site already had over 500 views. And it got me thinking what if this is a live project that is not been manage by an IaC and i want to start managing them through IaC. 
This led me to discover the power of the **__Terraform import__** command. 

### **🧠 What is terraform import?**
The `terraform import` command is used to bring existing resources, which were not originally created or managed by Terraform, under Terraform's management,  allowing you to manage the lifecycle of these resources using Terraform configurations and state, aslo known as Infrastructure as Code.
The syntax for the command is as follows:
```
terraform import [options] ADDRESS ID
```
#### **ADDR** – a valid resources address (e.g. aws_instance.instance_name)
#### **ID** – A resource unique identifier in the cloud provider, which is dependent on the resource type being imported. (e.g arn value of aws resoures)

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

It's critical to realize that the terraform.tfstate file is an essential reference document for Terraform. It takes this state file into consideration when performing any subsequent operations. To ensure that there is as little to no difference as possible between them (`.tf file` and `terraform state file`), you must examine the state file and modify your configuration appropriately, which means on every modification you run `terraform plan` to see the changes that will be made.
**`PS:`** To reach a state of zero difference, you must further align your resource block with the state file. 

It is equally important to note that, in bringing an existing infrastructure under Infrastructure as Code (IaC) management can be tedious, especially when the deployment is complex and intricate. You often can’t import everything at once; instead, you’ll need to bring resources into Terraform gradually and intentionally. That’s why it’s crucial to first identify and decide which parts of the infrastructure you want Terraform to manage. A well-drawn architecture diagram can be a game-changer here; it helps you visualise the entire system, break it into manageable pieces, and map out a clear plan for importing each component into Terraform.

### Terraform import use cases
1. **Migrating Existing Infrastructure**: When an organization has existing cloud resources created manually or through other tools, they can use `terraform import` to bring those resources under Terraform management without having to recreate them.
2. **Hybrid Environments**: In scenarios where some resources are managed by Terraform and others are not, `terraform import` allows teams to gradually transition resources to Terraform management.
3. **Disaster Recovery**: In the event of a disaster recovery situation where resources need to be recreated, `terraform import` can be used to bring the newly created resources under Terraform management.

### **Conclusion**
Revisiting this project helped me to learn more on how to bridge the gap between manual cloud setup and full IaC adoption by using Terraform import. 