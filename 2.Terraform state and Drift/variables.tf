variable "aws_region" {
  description = "The aws region to deploy in."
  type        = string
  default     = "ap-south-1"
}

variable "aws_tagging" {
  description = "Resource tags."
  type        = map(string)
  default = {
    "Team"        = "security",
    "Environment" = "dev"
  }
}

variable "desired_azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}