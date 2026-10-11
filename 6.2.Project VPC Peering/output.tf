output "vpc_ids" {
  value = {
    vpc_a = module.vpc_a.vpc_id
    vpc_b = module.vpc_b.vpc_id
  }
}

output "peering_id" {
  value = aws_vpc_peering_connection.inter.id
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
    ec2_a = "aws ssm start-session --target ${module.ec2_a.instance_id} --region ${var.mumbai_region}"
    ec2_b = "aws ssm start-session --target ${module.ec2_b.instance_id} --region ${var.mumbai_region}"
    ec2_c = "aws ssm start-session --target ${module.ec2_c.instance_id} --region ${var.virginia_region}"
  }
}
