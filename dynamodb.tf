resource "aws_dynamodb_table" "job_check" {
  name         = "JobCheck"
  billing_mode = "PAY_PER_REQUEST" # Use on-demand billing
  hash_key     = "id"              # Partition Key

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Application = "JobCheckService"
  }
}

resource "aws_dynamodb_table" "job_check_response" {
  name         = "JobCheckResponse"
  billing_mode = "PAY_PER_REQUEST" # Use on-demand billing
  hash_key     = "id"              # Partition Key

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "jobCheckId"
    type = "S"
  }

  # GSI for querying by JobCheckId
  global_secondary_index {
    name            = "jobCheckId-index"
    hash_key        = "jobCheckId"
    projection_type = "ALL"
  }

  tags = {
    Application = "JobCheckService"
  }
}
