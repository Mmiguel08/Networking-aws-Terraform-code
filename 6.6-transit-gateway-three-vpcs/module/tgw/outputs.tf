output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "attachment_ids" {
  value = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}

output "default_route_table_id" {
  value = aws_ec2_transit_gateway.this.association_default_route_table_id
}
