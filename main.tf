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

# add item to the dynamodb table
resource "aws_dynamodb_table_item" "cloudResumeViewsTable_item" {
  table_name = aws_dynamodb_table.cloudResumeViewsTable.name
  hash_key   = aws_dynamodb_table.cloudResumeViewsTable.hash_key

  item = <<ITEM
    {
        "id": {"S": "1"},
        "views": {"N": "1"}
    }
    ITEM
}

# creating iam policy
resource "aws_iam_policy" "dynamoDBLambdaPolicy_cloudResume" {
  name        = "dynamoDBLambdaPolicy_cloudResume"
  path        = "/"
  description = "iam Policy for dynamoDB and lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs: CreateLogGroup",
          "logs: CreateLogStream",
          "logs: PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/cloudResumeViewsTable"
      },
    ]
  })
}

# Before the Lambda function can be implemented an IAM role is needed
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

# attaching the policy to the role using terraform resources.
resource "aws_iam_role_policy_attachment" "lambdaPolicy_attachment" {
  role       = aws_iam_role.lambdaRole_cloudResume.name
  policy_arn = aws_iam_policy.dynamoDBLambdaPolicy_cloudResume.arn
}

# Defining the AWS Lambda Function Resource 
resource "aws_lambda_function" "resumeViewCounter" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  function_name    = "resumeViewCounter"
  role             = aws_iam_role.lambdaRole_cloudResume.arn
  handler          = "lambdaFunc.lambda_handler"
  runtime          = "python3.12"
}

# creating zip files to upload via terraform.
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/packedLambda.zip"
}

# creating a function url for the lambda function
resource "aws_lambda_function_url" "resumeViewCounter_functionURL" {
  function_name      = aws_lambda_function.resumeViewCounter.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://resume.juwonlo.com"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}