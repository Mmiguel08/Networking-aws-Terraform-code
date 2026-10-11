output "service_name" {
  value = aws_vpc_endpoint_service.this.service_name
}

output "service_id" {
  value = aws_vpc_endpoint_service.this.id
}

output "nlb_arn" {
  value = aws_lb.this.arn
}

output "nlb_dns_name" {
  value = aws_lb.this.dns_name
}
