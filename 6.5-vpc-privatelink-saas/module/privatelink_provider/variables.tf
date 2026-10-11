variable "name" {
  description = "Prefix for the NLB, target group and endpoint service"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "nlb_subnet_ids" {
  description = "Private subnets where the internal NLB is placed"
  type        = list(string)
}

variable "target_instance_id" {
  description = "Instance that runs the service"
  type        = string
}

variable "port" {
  description = "TCP port of the service"
  type        = number
  default     = 80
}

variable "allowed_principals" {
  description = "IAM principals (ARNs) allowed to create endpoints to this service"
  type        = list(string)
}

variable "acceptance_required" {
  description = "true = the provider must manually accept each endpoint connection"
  type        = bool
  default     = false
}
