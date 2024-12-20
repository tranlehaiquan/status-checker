# modules/lambda_sqs/variables.tf
variable "region" {
  type = string
}

variable "main_region" {
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

variable "policy_access_database_arn" {
  type = string
}