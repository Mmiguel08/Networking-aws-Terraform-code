variable "aws_region" {
  description = "The Region where the resource will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "az_zone" {
  type    = string
  default = "ap-south-1a"
}

variable "aws_key_pair" {
  description = "The key pair for the Instance"
  type        = string
  default     = "key-pem"
}
