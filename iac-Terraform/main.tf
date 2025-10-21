# Create dynamoDB table to use
resource "aws_dynamodb_table" "cloud-resume" {
  name           = "cloud-resume"
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
resource "aws_dynamodb_table_item" "cloud_resume_Item" {
  table_name = aws_dynamodb_table.cloud-resume.name
  hash_key   = aws_dynamodb_table.cloud-resume.hash_key

  item = <<ITEM
    {
      "id": {"S": "1"},
      "views": {"N": "98"}
    }
    ITEM
}

# creating iam policy
resource "aws_iam_policy" "dynamoDBLambdaPolicy_resume" {
  name        = "dynamoDBLambdaPolicy_resume"
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
        "Resource" : "arn:aws:dynamodb:*:*:table/cloud-resume"
      },
    ]
  })
}

# lambda IAM role
resource "aws_iam_role" "lambdaRole_resume" {
  name = "lambdaRole_resume"

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
  role       = aws_iam_role.lambdaRole_resume.name
  policy_arn = aws_iam_policy.dynamoDBLambdaPolicy_resume.arn
}


# Package the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambdaFunc.py"
  output_path = "${path.module}/../lambda/counter_func.zip"
}

# Defining the AWS Lambda Function Resource to interact with DynamoDB
resource "aws_lambda_function" "cloudResumeCounter" {
  function_name = "cloudResumeCounter"
  role          = aws_iam_role.lambdaRole_resume.arn
  handler       = "lambdaFunc.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# creating a function url for the lambda function
resource "aws_lambda_function_url" "resumeViewCounter_functionURL" {
  function_name      = aws_lambda_function.cloudResumeCounter.function_name
  authorization_type = "NONE"

  # cors {
  #   allow_credentials = true
  #   allow_origins     = ["https://resume.juwonlo.com"]
  #   allow_methods     = ["GET", "POST"]
  #   allow_headers     = ["date", "keep-alive"]
  #   expose_headers    = ["keep-alive", "date"]
  #   max_age           = 86400
  # }
}


# resource "aws_lambda_permission" "allow_function_url_invoke" {
#   statement_id              = "FunctionURLAllowInvokeAction"
#   action                    = "lambda:InvokeFunctionUrl"
#   function_name             = aws_lambda_function.cloudResumeCounter.function_name
#   principal                 = "*"
#   function_url_auth_type    = "NONE"
# }
