# modules/lambda_sqs/main.tf
provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "main_region"
  region = var.main_region
}

resource "aws_lambda_function" "lambda_function" {
  function_name       = "lambda_check_status"
  handler             = "index.handler"
  runtime             = "nodejs20.x"
  role                = aws_iam_role.lambda_exec.arn
  filename            = var.lambda_filename
  source_code_hash    = var.lambda_source_code_hash

  timeout = 15
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_${var.region}"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_runner_database" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = var.policy_access_database_arn
}

resource "aws_sqs_queue" "message_queue_region" {
  name = "message_queue_region_${var.region}"
}

# policy for lambda to access sqs
resource "aws_iam_policy" "sqs_policy" {
  name        = "sqs_policy_${var.region}"
  description = "Allow lambda to send message to sqs"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:*"
        ],
        Resource = aws_sqs_queue.message_queue_region.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}

# trigger lambda when message is sent to sqs
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.message_queue_region.arn
  function_name    = aws_lambda_function.lambda_function.arn
  batch_size       = 1
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.message_queue_region.arn
  raw_message_delivery = true
  provider = aws.main_region
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.message_queue_region.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.message_queue_region.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.sns_topic_arn
          }
        }
      }
    ]
  })
}