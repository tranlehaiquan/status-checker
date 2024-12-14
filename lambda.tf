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


resource "aws_lambda_function" "lambda_get_check_by_id" {
  function_name    = "lambda_get_check_by_id"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_api_rest_exec.arn
  filename         = data.archive_file.lambda_function_payload_getCheckById.output_path
  source_code_hash = data.archive_file.lambda_function_payload_getCheckById.output_base64sha256
  provider         = aws.main_region
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

resource "aws_lambda_permission" "api_gateway_permission_get_check_by_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_check_by_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
  provider      = aws.main_region
}