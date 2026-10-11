terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-privatelink-endpoint-sg"
  description = "Allows the service port from the VPC to the PrivateLink endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "Service port from the VPC"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.name}-privatelink-endpoint-sg" }
}

resource "aws_vpc_endpoint" "this" {
  vpc_id             = var.vpc_id
  service_name       = var.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.this.id]

  # Private DNS for third-party services needs a domain the provider verified,
  # so we use the endpoint's own DNS name instead.
  private_dns_enabled = false

  tags = { Name = "${var.name}-privatelink-endpoint" }
}
