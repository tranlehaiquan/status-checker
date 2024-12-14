provider "aws" {
  alias  = "main_region"
  region = var.main_region
}

# create a gateway here
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "gateway"
  description = "API Gateway for the lambda functions"
  provider    = aws.main_region
}

data "archive_file" "lambda_function_payload_createCheckStatus" {
  type        = "zip"
  source_dir  = "./dist/api/createCheck"
  output_path = "./zip/lambda_function_payload_createCheckStatus.zip"
}

data "archive_file" "lambda_function_payload_getCheckById" {
  type        = "zip"
  source_dir  = "./dist/api/getCheckById"
  output_path = "./zip/lambda_function_payload_getCheckById.zip"
}

data "archive_file" "lambda_function_payload_getCheck" {
  type        = "zip"
  source_dir  = "./dist/api/getCheck"
  output_path = "./zip/lambda_function_payload_getCheck.zip"
}

resource "aws_iam_role" "lambda_api_rest_exec" {
  name = "lambda_api_rest_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  provider = aws.main_region
}

resource "aws_iam_policy" "lambda_publish_sns_policy" {
  name        = "lambda_publish_sns_policy"
  description = "IAM policy for Lambda to publish to SNS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.check_status_topic.arn
      }
    ]
  })
  provider = aws.main_region
}

resource "aws_iam_role_policy_attachment" "lambda_publish_sns_attachment" {
  role       = aws_iam_role.lambda_api_rest_exec.name
  policy_arn = aws_iam_policy.lambda_publish_sns_policy.arn
  provider   = aws.main_region
}

resource "aws_lambda_function" "lambda_create_check" {
  function_name    = "lambda_create_check"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_api_rest_exec.arn
  filename         = data.archive_file.lambda_function_payload_createCheckStatus.output_path
  source_code_hash = data.archive_file.lambda_function_payload_createCheckStatus.output_base64sha256
  provider         = aws.main_region
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.check_status_topic.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_check" {
  function_name    = "lambda_get_check"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_api_rest_exec.arn
  filename         = "./zip/lambda_function_payload_getCheck.zip"
  source_code_hash = data.archive_file.lambda_function_payload_getCheck.output_base64sha256
  provider         = aws.main_region
}

# POST /check endpoint
resource "aws_api_gateway_resource" "check" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "check"
  provider    = aws.main_region
}

resource "aws_api_gateway_method" "method_create_check" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.check.id
  http_method   = "POST"
  authorization = "NONE"
  provider      = aws.main_region
}

resource "aws_api_gateway_integration" "integration_create_check" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.check.id
  http_method             = aws_api_gateway_method.method_create_check.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.lambda_create_check.invoke_arn
  provider                = aws.main_region
}
resource "aws_api_gateway_method" "method_get_check" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.check.id
  http_method   = "GET"
  authorization = "NONE"
  provider      = aws.main_region
}

resource "aws_api_gateway_integration" "integration_get_check" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_method.method_get_check.resource_id
  http_method             = aws_api_gateway_method.method_get_check.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_get_check.invoke_arn
  provider                = aws.main_region
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_create_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
  provider      = aws.main_region
}

resource "aws_lambda_permission" "api_gateway_permission_get_check" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
  provider      = aws.main_region
}

# SNS
resource "aws_sns_topic" "check_status_topic" {
  name     = "check_status_topic"
  provider = aws.main_region
}

# DynamoDB
# JobCheck Table
resource "aws_dynamodb_table" "job_check" {
  name           = "JobCheck"
  billing_mode   = "PAY_PER_REQUEST" # Use on-demand billing
  hash_key       = "id" # Partition Key

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Application = "JobCheckService"
  }
}

# JobCheckResponse Table
resource "aws_dynamodb_table" "job_check_response" {
  name           = "JobCheckResponse"
  billing_mode   = "PAY_PER_REQUEST" # Use on-demand billing
  hash_key       = "id" # Partition Key

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "JobCheckId"
    type = "S"
  }

  # GSI for querying by JobCheckId
  global_secondary_index {
    name            = "JobCheckId-index"
    hash_key        = "JobCheckId"
    projection_type = "ALL"
  }

  tags = {
    Application = "JobCheckService"
  }
}

# policy for lambda to access dynamodb
resource "aws_iam_policy" "lambda_database" {
  name = "lambda_database_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.job_check.arn,
          aws_dynamodb_table.job_check.arn,
          "${aws_dynamodb_table.job_check.arn}/index/*",
          aws_dynamodb_table.job_check_response.arn,
          aws_dynamodb_table.job_check_response.arn,
          "${aws_dynamodb_table.job_check_response.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_database_attachment" {
  name       = "lambda_database_attachment"
  roles      = [aws_iam_role.lambda_api_rest_exec.name]
  policy_arn = aws_iam_policy.lambda_database.arn
}
