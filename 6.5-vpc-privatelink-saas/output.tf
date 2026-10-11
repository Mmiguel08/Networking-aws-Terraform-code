output "vpc_ids" {
  value = {
    vpc_a_consumer = module.vpc_a.vpc_id
    vpc_b_provider = module.vpc_b.vpc_id
  }
}

output "endpoint_service_name" {
  description = "Name of the VPC Endpoint Service published by the provider"
  value       = module.privatelink_provider.service_name
}

output "nlb_dns_name" {
  description = "Internal NLB in front of EC2-C (only reachable inside VPC-B)"
  value       = module.privatelink_provider.nlb_dns_name
}

output "endpoint_dns_name" {
  description = "DNS name of the interface endpoint in VPC-A (use this from EC2-B)"
  value       = module.privatelink_consumer.dns_name
}

output "endpoint_eni_ids" {
  description = "ENI(s) of the interface endpoint (the ENI in the diagram)"
  value       = module.privatelink_consumer.eni_ids
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
    ec2_c = {
      id         = module.ec2_c.instance_id
      private_ip = module.ec2_c.private_ip
    }
  }
}

output "ssm_connect_commands" {
  description = "Commands to open SSM sessions on the VMs"
  value = {
    ec2_a = "aws ssm start-session --target ${module.ec2_a.instance_id} --region ${var.region}"
    ec2_b = "aws ssm start-session --target ${module.ec2_b.instance_id} --region ${var.region}"
    ec2_c = "aws ssm start-session --target ${module.ec2_c.instance_id} --region ${var.region}"
  }
}

output "privatelink_test_commands" {
  description = "Run these inside EC2-B (consumer private subnet) after opening an SSM session"
  value = [
    "curl -s http://${module.privatelink_consumer.dns_name}:${var.service_port}",
    "curl -s -m 5 http://${module.ec2_c.private_ip}:${var.service_port} || echo 'no route to VPC-B (expected: only PrivateLink connects the two VPCs)'",
  ]
}
