resource "aws_apigatewayv2_api" "gateway" {
  name          = "gateway"
  description   = "HTTP API Gateway for the lambda functions"
  protocol_type = "HTTP"
  provider      = aws.main_region

  cors_configuration {
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_integration" "integration_create_check" {
  api_id             = aws_apigatewayv2_api.gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.lambda_create_check.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
  provider           = aws.main_region
}

resource "aws_apigatewayv2_integration" "integration_get_check" {
  api_id             = aws_apigatewayv2_api.gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.lambda_get_check.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
  provider           = aws.main_region
}

resource "aws_apigatewayv2_integration" "integration_get_check_by_id" {
  api_id             = aws_apigatewayv2_api.gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.lambda_get_check_by_id.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
  provider           = aws.main_region
}

resource "aws_apigatewayv2_route" "route_create_check" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "POST /check"
  target    = "integrations/${aws_apigatewayv2_integration.integration_create_check.id}"
  provider  = aws.main_region
}

resource "aws_apigatewayv2_route" "route_get_check" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET /check"
  target    = "integrations/${aws_apigatewayv2_integration.integration_get_check.id}"
  provider  = aws.main_region
}

resource "aws_apigatewayv2_route" "route_get_check_by_id" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET /check/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.integration_get_check_by_id.id}"
  provider  = aws.main_region
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "dev"
  auto_deploy = true
  provider    = aws.main_region
}