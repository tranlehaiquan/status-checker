provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"
}

# create a gateway here
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "gateway"
  description = "API Gateway for the lambda functions"
  provider    = aws.ap_southeast_1
}

data "archive_file" "lambda_function_payload_createCheckStatus" {
  type        = "zip"
  source_dir  = "./dist/api/createCheck"
  output_path = "./zip/lambda_function_payload_createCheckStatus.zip"
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
  provider = aws.ap_southeast_1
}

resource "aws_lambda_function" "lambda_create_check" {
  function_name    = "lambda_create_check"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_api_rest_exec.arn
  filename         = "./zip/lambda_function_payload_createCheckStatus.zip"
  source_code_hash = data.archive_file.lambda_function_payload_createCheckStatus.output_base64sha256
  provider         = aws.ap_southeast_1
}

resource "aws_lambda_function" "lambda_get_check" {
  function_name    = "lambda_get_check"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_api_rest_exec.arn
  filename         = "./zip/lambda_function_payload_getCheck.zip"
  source_code_hash = data.archive_file.lambda_function_payload_getCheck.output_base64sha256
  provider         = aws.ap_southeast_1
}

# POST /check endpoint
resource "aws_api_gateway_resource" "check" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "check"
  provider    = aws.ap_southeast_1
}

resource "aws_api_gateway_method" "method_create_check" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.check.id
  http_method   = "POST"
  authorization = "NONE"
  provider      = aws.ap_southeast_1
}

resource "aws_api_gateway_integration" "integration_create_check" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.check.id
  http_method             = aws_api_gateway_method.method_create_check.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_create_check.invoke_arn
  provider                = aws.ap_southeast_1
}
resource "aws_api_gateway_method" "method_get_check" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.check.id
  http_method   = "GET"
  authorization = "NONE"
  provider      = aws.ap_southeast_1
}

resource "aws_api_gateway_integration" "integration_get_check" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.check.id
  http_method             = aws_api_gateway_method.method_get_check.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_get_check.invoke_arn
  provider                = aws.ap_southeast_1
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_create_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
  provider      = aws.ap_southeast_1
}

resource "aws_lambda_permission" "api_gateway_permission_get_check" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
  provider      = aws.ap_southeast_1
}

# SNS
resource "aws_sns_topic" "check_status_topic" {
  name     = "check_status_topic"
  provider = aws.ap_southeast_1
}
