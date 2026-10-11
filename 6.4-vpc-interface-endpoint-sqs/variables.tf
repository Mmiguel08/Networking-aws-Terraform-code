variable "project_name" {
  description = "Prefix used in resource names (lowercase letters, numbers and hyphens only)"
  type        = string
  default     = "vpc-sqs-endpoint-lab"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet (EC2-A)"
  type        = string
  default     = "10.100.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet (EC2-B)"
  type        = string
  default     = "10.100.11.0/24"
}

variable "enable_sqs_interface_endpoint" {
  description = "true = SQS interface endpoint (ENI + PrivateLink) in the private subnet, as in the diagram. false = EC2-B has no path to SQS."
  type        = bool
  default     = true
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "vpc-sqs-endpoint-lab"
    ManagedBy = "terraform"
  }
}
