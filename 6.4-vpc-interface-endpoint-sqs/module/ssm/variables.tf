variable "name" {
  type = string
}

variable "sqs_queue_arns" {
  description = "Optional. Queues the instances may send to / receive from (adds an inline policy to the role)"
  type        = list(string)
  default     = []
}
