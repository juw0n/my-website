# Create dynamoDB table to use
resource "aws_dynamodb_table" "cloudResumeViewsTable" {
  name           = "cloudResumeViewsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# lambda IAM role
resource "aws_iam_role" "lambdaRole_cloudResume" {
  name = "lambdaRole_cloudResume"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Package the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambdaFunc.py"
  output_path = "${path.module}/../lambda/counter_func.zip"
}

# Defining the AWS Lambda Function Resource to interact with DynamoDB
resource "aws_lambda_function" "resumeViewCounter" {
  function_name = "resumeViewCounter"
  role          = aws_iam_role.lambdaRole_cloudResume.arn
  handler       = "lambdaFunc.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# creating a function url for the lambda function
resource "aws_lambda_function_url" "resumeViewCounter_functionURL" {
  function_name      = aws_lambda_function.resumeViewCounter.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://juwonlo.xyz"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}