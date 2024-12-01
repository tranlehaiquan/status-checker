variable "aws_regions" {
  type = string
  default = "ap-southeast-1"
}

provider "aws" {
  region = var.aws_regions
}

data "archive_file" "lambda_function_payload" {
  type        = "zip"
  source_dir  = "./dist/checkStatus"
  output_path = "./zip/lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name       = "lambda_check_status"
  handler             = "index.handler"
  runtime             = "nodejs20.x"
  role                = aws_iam_role.lambda_exec.arn
  filename            = "./zip/lambda_function_payload.zip"
  source_code_hash    = data.archive_file.lambda_function_payload.output_base64sha256
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

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
