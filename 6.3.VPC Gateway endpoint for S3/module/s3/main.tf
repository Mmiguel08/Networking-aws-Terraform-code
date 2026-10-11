resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true # lab only: allows terraform destroy with objects inside

  tags = { Name = var.bucket_name }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Test object to read from EC2-B
resource "aws_s3_object" "hello" {
  bucket  = aws_s3_bucket.this.id
  key     = "hello.txt"
  content = "Hello from S3 - reached through the VPC Gateway Endpoint!\n"
}
