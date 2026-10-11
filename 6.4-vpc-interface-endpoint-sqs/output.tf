output "vpc_id" {
  value = module.vpc.vpc_id
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_endpoint_id" {
  description = "null when enable_sqs_interface_endpoint = false"
  value       = module.vpc.sqs_endpoint_id
}

output "sqs_endpoint_eni_ids" {
  description = "ENIs created by the SQS interface endpoint (the ENI in the diagram)"
  value       = module.vpc.sqs_endpoint_eni_ids
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

output "sqs_test_commands" {
  description = "Run these inside EC2-B (private subnet) after opening an SSM session"
  value = [
    "getent hosts sqs.${var.region}.amazonaws.com",
    "aws sqs send-message --queue-url ${module.sqs.queue_url} --message-body 'hello from EC2-B' --region ${var.region}",
    "aws sqs receive-message --queue-url ${module.sqs.queue_url} --region ${var.region}",
  ]
}
