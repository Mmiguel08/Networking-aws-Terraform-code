output "instance_profile_name" {
  value = aws_iam_instance_profile.ssm.name
}

output "role_arn" {
  value = aws_iam_role.ssm.arn
}
