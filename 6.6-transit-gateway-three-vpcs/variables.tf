variable "project_name" {
  description = "Prefix used in resource names (lowercase letters, numbers and hyphens only)"
  type        = string
  default     = "tgw-lab"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

# ---- VPC A (public subnet with jump host + private subnet) ----
variable "vpc_a_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "Public subnet in VPC A (jump host)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_a_cidr" {
  description = "Private subnet in VPC A (instance A)"
  type        = string
  default     = "10.0.1.0/24"
}

# ---- VPC B (private subnet) ----
variable "vpc_b_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "private_subnet_b_cidr" {
  description = "Private subnet in VPC B (instance B)"
  type        = string
  default     = "10.1.1.0/24"
}

# ---- VPC C (private subnet) ----
variable "vpc_c_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "private_subnet_c_cidr" {
  description = "Private subnet in VPC C (instance C)"
  type        = string
  default     = "10.2.1.0/24"
}

variable "tgw_summary_cidr" {
  description = "Summary route that sends traffic for all VPCs to the Transit Gateway"
  type        = string
  default     = "10.0.0.0/8"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "tgw-lab"
    ManagedBy = "terraform"
  }
}
