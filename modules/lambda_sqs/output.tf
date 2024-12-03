# modules/lambda_sqs/outputs.tf
output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.message_queue_region.url
}
# output "sns_subscription_arn" {
#   value = aws_sns_topic_subscription.sns_to_sqs.arn
# }