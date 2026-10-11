variable "project_name" {
  description = "Prefix used in resource names"
  type        = string
  default     = "vpc-peering-lab"
}

variable "mumbai_region" {
  type    = string
  default = "ap-south-1"
}

variable "virginia_region" {
  type    = string
  default = "us-east-1"
}

# ---- VPC-A (Mumbai) ----
variable "vpc_a_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "Public subnet in VPC-A (EC2-A)"
  type        = string
  default     = "10.100.0.0/24"
}

variable "private_subnet_a_cidr" {
  description = "Private subnet in VPC-A (EC2-B)"
  type        = string
  default     = "10.100.11.0/24"
}

# ---- VPC-B (N. Virginia) ----
variable "vpc_b_cidr" {
  type    = string
  default = "10.200.0.0/16"
}

variable "private_subnet_b_cidr" {
  description = "Private subnet in VPC-B (EC2-C)"
  type        = string
  default     = "10.200.11.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "vpc-peering-lab"
    ManagedBy = "terraform"
  }
}
