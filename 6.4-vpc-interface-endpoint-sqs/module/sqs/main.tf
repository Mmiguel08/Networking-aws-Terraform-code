resource "aws_sqs_queue" "this" {
  name                      = var.queue_name
  sqs_managed_sse_enabled   = true # server-side encryption with SQS-managed keys
  message_retention_seconds = 86400
  receive_wait_time_seconds = 5 # short long-polling, friendlier for CLI tests

  tags = { Name = var.queue_name }
}
