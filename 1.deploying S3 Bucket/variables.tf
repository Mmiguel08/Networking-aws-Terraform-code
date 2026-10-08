variable "s3_nucket_name" {
  description = "The Unique bucket name"
  type        = string
  default     = "ashelga-s3-bucket-09099"
}

variable "aws_region" {
  description = "The region where the resources is deployed"
  type        = string
  default     = "ap-south-1"
}

variable "aws_tagging" {
  description = "The tag for the resorces"
  type        = map(string)
  default = {
    "Team"       = "Security",
    "Environmet" = "dev"
  }
}