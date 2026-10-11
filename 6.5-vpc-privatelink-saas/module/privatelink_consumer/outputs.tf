output "endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "dns_name" {
  description = "Regional DNS name of the endpoint"
  value       = aws_vpc_endpoint.this.dns_entry[0].dns_name
}

output "eni_ids" {
  value = aws_vpc_endpoint.this.network_interface_ids
}
