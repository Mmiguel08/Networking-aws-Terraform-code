variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR allowed to reach the endpoint ENI"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where the endpoint ENI is created"
  type        = list(string)
}

variable "service_name" {
  description = "Endpoint service name published by the provider"
  type        = string
}

variable "port" {
  description = "TCP port of the service"
  type        = number
  default     = 80
}
