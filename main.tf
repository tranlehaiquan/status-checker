data "archive_file" "lambda_function_trigger_check" {
  type        = "zip"
  source_dir  = "./dist/trigger/pingRunner"
  output_path = "./zip/pingRunner.zip"
}

# region United States
module "runner_us" {
  source                  = "./modules/lambda_sqs"
  region                  = "us-west-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}

# Asia Pacific
module "runner_asia" {
  source                  = "./modules/lambda_sqs"
  region                  = "ap-southeast-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}

module "runner_asia_jp" {
  source                  = "./modules/lambda_sqs"
  region                  = "ap-northeast-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}

# Canada
module "runner_canada" {
  source                  = "./modules/lambda_sqs"
  region                  = "ca-central-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}

# Europe
module "runner_europe" {
  source                  = "./modules/lambda_sqs"
  region                  = "eu-west-1"
  lambda_filename         = data.archive_file.lambda_function_trigger_check.output_path
  lambda_source_code_hash = data.archive_file.lambda_function_trigger_check.output_base64sha256
  sns_topic_arn           = aws_sns_topic.check_status_topic.arn
  main_region             = var.main_region
  policy_access_database_arn =  aws_iam_policy.lambda_database.arn
}