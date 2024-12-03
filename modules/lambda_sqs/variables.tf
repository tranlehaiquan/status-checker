# modules/lambda_sqs/variables.tf
variable "region" {
  type = string
}

variable "lambda_filename" {
  type = string
}

variable "lambda_source_code_hash" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}