output "ss_resources" {
  value = {
    iam_arn  = aws_iam_role.default_host_management.arn
    iam_name = aws_iam_role.default_host_management.name
  }
  description = "SSM resources properties"
}