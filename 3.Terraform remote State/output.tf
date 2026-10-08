output "s3_bucket_details" {
  description = "The details about the S3_buckets"
  value = [
    "Bucket ID: ${aws_s3_bucket.ashelga_s3_bucket_tf_state.id}",
    "Bucket ARN: ${aws_s3_bucket.ashelga_s3_bucket_tf_state.arn}",
    "Bucket Domain name:${aws_s3_bucket.ashelga_s3_bucket_tf_state.bucket_domain_name}"
  ]
}