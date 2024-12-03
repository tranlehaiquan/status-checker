data "archive_file" "lambda_function_payload" {
  type        = "zip"
  source_dir  = "./dist/checkStatus"
  output_path = "./zip/lambda_function_payload.zip"
}

module "lambda_sqs_1" {
  source = "./modules/lambda_sqs"
  region = "ap-southeast-1"
  lambda_filename = data.archive_file.lambda_function_payload.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_payload.output_base64sha256
  sns_topic_arn = aws_sns_topic.check_status_topic.arn
}

# module "lambda_sqs_2" {
#   source = "./modules/lambda_sqs"
#   region = "ap-southeast-2"
#   lambda_filename = data.archive_file.lambda_function_payload.output_path
#   lambda_source_code_hash = data.archive_file.lambda_function_payload.output_base64sha256
#   sns_topic_arn = aws_sns_topic.check_status_topic.arn
# }
