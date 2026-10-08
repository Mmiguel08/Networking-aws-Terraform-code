resource "aws_s3_bucket" "ashelga_s3_bucket_tf_state" {
  bucket        = var.s3_nucket_name
  tags          = var.aws_tagging
  force_destroy = true
}

//bucket versioning
resource "aws_s3_bucket_versioning" "ashelga_s3_bucket_versioning" {
  bucket = aws_s3_bucket.ashelga_s3_bucket_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}