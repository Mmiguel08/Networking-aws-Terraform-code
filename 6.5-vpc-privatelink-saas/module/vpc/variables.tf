variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "public_subnet_cidr" {
  description = "Optional. If set, creates a public subnet, an Internet Gateway and a public route table"
  type        = string
  default     = null
}

variable "private_subnet_cidr" {
  type = string
}

variable "secondary_private_subnet_cidr" {
  description = "Optional. If set, creates a second private subnet (same route table as the first one)"
  type        = string
  default     = null
}

variable "enable_ssm_endpoints" {
  description = "Creates the SSM interface VPC endpoints (required for private instances without NAT)"
  type        = bool
  default     = true
}
