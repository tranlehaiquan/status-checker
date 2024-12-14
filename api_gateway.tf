resource "aws_api_gateway_rest_api" "gateway" {
  name        = "gateway"
  description = "API Gateway for the lambda functions"
  provider    = aws.main_region
}

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

resource "aws_api_gateway_resource" "check_by_id" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_resource.check.id
  path_part   = "{id}"
  provider    = aws.main_region
}

resource "aws_api_gateway_method" "method_get_check_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.check_by_id.id
  http_method   = "GET"
  authorization = "NONE"
  provider      = aws.main_region
}

resource "aws_api_gateway_integration" "integration_get_check_by_id" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_method.method_get_check_by_id.resource_id
  http_method             = aws_api_gateway_method.method_get_check_by_id.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_get_check_by_id.invoke_arn
  provider                = aws.main_region
}
