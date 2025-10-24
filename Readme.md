Revisiting a simple project i did about two years ago, first to implement an idea and research i did on manageing an existing project with IAC, Terraform in my case, also to complete the project because i think and from reasearch most people dont actually do the backend IAC part of the project, my conclusion from limited resources online.

It is an online challenge called [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/). it is a hands-on cloud engineering project that helps you build a real-world, serverless web application using any of the cloud providers (AWS, Azure or GCP), I use AWS. It’s more than just a static site, it connects front-end, back-end, CI/CD and Infrastructure as Code concepts into one project not leaving out security.

With the abundance of documentations and resources available online, I’ll walk you through a high level of how I designed and deployed my Cloud Resume Challenge project using AWS and GitHub Actions, with a clean, scalable architecture.

Project Overview
Here’s what the project does:

* Hosts a personal resume website.
* Displays a visitor counter powered by AWS Lambda and DynamoDB.
* Uses a CI/CD pipeline for automated testing and deployment.
* Secures the site with HTTPS via AWS Certificate Manager.

The high-level architecture looks like this:
![Project Architecture Diagram](https://github.com/juw0n/my-website/blob/main/AWS%20Resume%20Achitecture.jpg)