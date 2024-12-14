resource "aws_sns_topic" "check_status_topic" {
  name     = "check_status_topic"
  provider = aws.main_region
}
