variable "project_name" {
  description = "Prefix used in resource names (lowercase letters, numbers and hyphens only)"
  type        = string
  default     = "vpc-privatelink-lab"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

# ---- VPC-A: Service Consumer ----
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
  description = "Private subnet in VPC-A (EC2-B + PrivateLink endpoint ENI)"
  type        = string
  default     = "10.100.11.0/24"
}

# ---- VPC-B: Service Provider ----
variable "vpc_b_cidr" {
  type    = string
  default = "10.200.0.0/16"
}

variable "nlb_subnet_b_cidr" {
  description = "Private subnet in VPC-B for the Network Load Balancer"
  type        = string
  default     = "10.200.11.0/24"
}

variable "app_subnet_b_cidr" {
  description = "Private subnet in VPC-B for the service instance (EC2-C)"
  type        = string
  default     = "10.200.12.0/24"
}

variable "service_port" {
  description = "TCP port exposed by the service through the NLB"
  type        = number
  default     = 80
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "vpc-privatelink-lab"
    ManagedBy = "terraform"
  }
}
