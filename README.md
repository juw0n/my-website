# 🌩️ Cloud Resume Challenge (AWS Edition)

## ✨ Introduction

Two years ago, I started a simple project to explore Infrastructure as Code (IaC) using Terraform. I recently revisited it with a fresh perspective — not just to complete it, but to dive deeper into managing existing cloud resources with IaC.

What sparked this? I noticed that many people skip the backend IaC part of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/), and I wanted to change that.

This challenge is a hands-on cloud engineering project that helps you build a real-world, serverless web application using AWS, Azure, or GCP. I chose AWS. It’s more than just a static site — it connects frontend, backend, CI/CD, and IaC concepts into one project, with security baked in.

---

## 🧱 Project Overview

> **Note:** To begin, you’ll need a domain name (e.g., from [Namecheap](https://namecheap.com)), an account with a cloud provider, and programmatic access credentials.

This project:

- Hosts a personal resume website
- Displays a visitor counter powered by AWS Lambda and DynamoDB
- Uses a CI/CD pipeline for automated testing and deployment
- Secures the site with HTTPS via AWS Certificate Manager

### 📐 Architecture Diagram

![Project Architecture Diagram](https://github.com/juw0n/my-website/blob/main/AWS%20Resume%20Achitecture.jpg)

---

## 🔧 Core AWS Components

### 1. Amazon S3 (Static Website Hosting)
- Website files are uploaded to an S3 bucket.
- Public access is disabled; HTTPS is enabled via CloudFront.

### 2. AWS CloudFront (CDN)
- Serves S3 content securely over HTTPS.
- Uses an SSL/TLS certificate from AWS Certificate Manager.

### 3. AWS Certificate Manager (SSL)
- Provides a free SSL/TLS certificate for the domain.
- Attached to the CloudFront distribution for secure access.

### 4. AWS Route 53 (DNS)
- Manages DNS settings linked to Namecheap.
- Routes traffic to CloudFront via an alias record.

### 5. AWS Lambda + DynamoDB (Visitor Counter)
- DynamoDB stores visitor count.
- A Python-based Lambda function retrieves and increments the count.
- Triggered via Lambda Function URL when the site loads.

> This setup is fully serverless — no EC2 instances to manage!

---

## 🔄 CI/CD Pipeline with GitHub Actions

To automate testing and deployment:

1. On every push to `main`, GitHub Actions triggers two workflows:
   - One syncs updated website files to S3.
   - The other runs tests on the Lambda function and deploys infrastructure via Terraform (if tests pass).

This ensures fast, reliable deployments with every change.

---

## 📦 Infrastructure as Code with Terraform

Following the challenge, most people use **ClickOps** (manual setup via AWS Console) to get started. But when I reached the IaC stage, I realized I’d need to recreate everything in Terraform — even though my site had over 500 views!

This led me to discover the power of the `terraform import` command.

---

## 🧠 What is `terraform import`?

`terraform import` brings existing resources under Terraform’s management — even if they weren’t created with Terraform.

### Syntax:
```bash
terraform import [options] ADDRESS ID
```
ADDRESS: Resource block name (e.g., aws_dynamodb_table.cloudResumeViewsTable)

ID: Unique identifier (e.g., ARN of the resource)
### Example: Importing DynamoDB Table
In `main.tf`:
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
`Import command`
```
terraform import aws_dynamodb_table.cloudResumeViewsTable arn:aws:dynamodb:us-east-1:357078656374:table/cloudResumeViewsTable
```
This command imports the existing DynamoDB table into Terraform’s state, allowing you to manage it as code.

The `terraform import` command only imports the resource into the Terraform state file; it does not automatically generate the corresponding configuration in the `.tf` file, also the resources block must exist in the `.tf` file for the resources to be imported.

### 🧩 Terraform Import Use Cases
* Migrating Existing Infrastructure: Bring manually created resources under Terraform control.
* Hybrid Environments: Gradually transition resources to IaC.
* Disaster Recovery: Re-import recreated resources after recovery.

## 🗺️ Planning Imports for Complex Deployments
Importing resources in a complex deployment can be tedious. You often can’t import everything at once — instead, bring resources into Terraform gradually and intentionally.
A well-drawn architecture diagram helps you:
* Visualize the system
* Break it into manageable pieces
* Map out a clear import plan

## ✅ Conclusion
Revisiting this project helped me bridge the gap between manual cloud setup and full IaC adoption. By using terraform import, I now manage all resources through code — making future updates safer, faster, and more scalable.