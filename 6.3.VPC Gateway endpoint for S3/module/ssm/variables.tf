variable "name" {
  type = string
}

variable "s3_bucket_arns" {
  description = "Optional. Buckets the instances may list/read/write (adds an inline policy to the role)"
  type        = list(string)
  default     = []
}
