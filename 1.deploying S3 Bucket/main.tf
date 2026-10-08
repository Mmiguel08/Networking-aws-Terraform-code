resource "aws_s3_bucket" "ashelga_s3_bucket_1" {
  bucket = var.s3_nucket_name
  tags   = var.aws_tagging
}