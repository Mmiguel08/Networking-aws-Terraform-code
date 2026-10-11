variable "name" {
  type = string
}

variable "attachments" {
  description = "VPC attachments keyed by a short name (for example a, b, c)"
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
}
