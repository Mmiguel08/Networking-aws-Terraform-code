output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_id" {
  description = "null when the VPC has no public subnet"
  value       = one(aws_subnet.public[*].id)
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_route_table_id" {
  description = "null when the VPC has no public subnet"
  value       = one(aws_route_table.public[*].id)
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "internet_gateway_id" {
  value = one(aws_internet_gateway.this[*].id)
}

output "s3_gateway_endpoint_id" {
  description = "null when the S3 gateway endpoint is disabled"
  value       = one(aws_vpc_endpoint.s3[*].id)
}
