output "vpc_id" {
  value = module.vpc.vpc_id
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "s3_gateway_endpoint_id" {
  description = "null when enable_s3_gateway_endpoint = false"
  value       = module.vpc.s3_gateway_endpoint_id
}

output "instances" {
  value = {
    ec2_a = {
      id         = module.ec2_a.instance_id
      private_ip = module.ec2_a.private_ip
      public_ip  = module.ec2_a.public_ip
    }
    ec2_b = {
      id         = module.ec2_b.instance_id
      private_ip = module.ec2_b.private_ip
    }
  }
}

output "ssm_connect_commands" {
  description = "Commands to open SSM sessions on the VMs"
  value = {
    ec2_a = "aws ssm start-session --target ${module.ec2_a.instance_id} --region ${var.region}"
    ec2_b = "aws ssm start-session --target ${module.ec2_b.instance_id} --region ${var.region}"
  }
}

output "s3_test_commands" {
  description = "Run these inside EC2-B (private subnet) after opening an SSM session"
  value = [
    "aws s3 ls s3://${module.s3.bucket_name} --region ${var.region}",
    "aws s3 cp s3://${module.s3.bucket_name}/hello.txt - --region ${var.region}",
    "echo from-ec2-b > /tmp/upload.txt && aws s3 cp /tmp/upload.txt s3://${module.s3.bucket_name}/upload.txt --region ${var.region}",
  ]
}
