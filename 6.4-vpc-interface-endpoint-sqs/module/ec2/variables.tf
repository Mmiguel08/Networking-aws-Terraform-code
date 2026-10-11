variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_profile" {
  description = "Instance profile name with AmazonSSMManagedInstanceCore"
  type        = string
}

variable "associate_public_ip" {
  description = "Assign a public IP (only for instances in a public subnet)"
  type        = bool
  default     = false
}

variable "allowed_ingress_cidr" {
  description = "CIDRs allowed to ping this instance"
  type        = list(string)
  default     = []
}
