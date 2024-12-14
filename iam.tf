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
