variable "aws_region" {
  description = "The aws region to deploy in."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_endpoints" {
  type        = list(string)
  description = "A list of VPC endpoints to create."
  default     = ["ssm", "ssmmessages"]
}