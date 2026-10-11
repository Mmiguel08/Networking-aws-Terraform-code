output "vpc_ids" {
  value = {
    vpc_a = module.vpc_a.vpc_id
    vpc_b = module.vpc_b.vpc_id
    vpc_c = module.vpc_c.vpc_id
  }
}

output "transit_gateway_id" {
  value = module.tgw.transit_gateway_id
}

output "tgw_attachment_ids" {
  value = module.tgw.attachment_ids
}

output "tgw_default_route_table_id" {
  description = "TGW default route table (shows one propagated route per VPC)"
  value       = module.tgw.default_route_table_id
}

output "instances" {
  value = {
    jump_host = {
      id         = module.ec2_jump.instance_id
      private_ip = module.ec2_jump.private_ip
      public_ip  = module.ec2_jump.public_ip
    }
    ec2_a = { id = module.ec2_a.instance_id, private_ip = module.ec2_a.private_ip }
    ec2_b = { id = module.ec2_b.instance_id, private_ip = module.ec2_b.private_ip }
    ec2_c = { id = module.ec2_c.instance_id, private_ip = module.ec2_c.private_ip }
  }
}

output "ssm_connect_commands" {
  description = "Commands to open SSM sessions on the VMs"
  value = {
    jump_host = "aws ssm start-session --target ${module.ec2_jump.instance_id} --region ${var.region}"
    ec2_a     = "aws ssm start-session --target ${module.ec2_a.instance_id} --region ${var.region}"
    ec2_b     = "aws ssm start-session --target ${module.ec2_b.instance_id} --region ${var.region}"
    ec2_c     = "aws ssm start-session --target ${module.ec2_c.instance_id} --region ${var.region}"
  }
}

output "connectivity_test_commands" {
  description = "Run these from any instance (for example the jump host) after opening an SSM session"
  value = [
    "ping -c 3 ${module.ec2_a.private_ip}   # instance A (VPC A)",
    "ping -c 3 ${module.ec2_b.private_ip}   # instance B (VPC B)",
    "ping -c 3 ${module.ec2_c.private_ip}   # instance C (VPC C)",
  ]
}

output "tgw_routes_command" {
  description = "Shows the routes learned by the TGW default route table"
  value       = "aws ec2 search-transit-gateway-routes --region ${var.region} --transit-gateway-route-table-id ${module.tgw.default_route_table_id} --filters Name=state,Values=active"
}
