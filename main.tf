data "archive_file" "lambda_function_trigger_check" {
  type        = "zip"
  source_dir  = "./dist/trigger/pingRunner"
  output_path = "./zip/pingRunner.zip"
}

module "lambda_sqs_1" {
  source                  = "./modules/lambda_sqs"
  region                  = "ap-southeast-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}

module "lambda_sqs_2" {
  source                  = "./modules/lambda_sqs"
  region                  = "ap-southeast-2"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}
