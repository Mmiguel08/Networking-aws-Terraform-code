terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_ec2_transit_gateway" "this" {
  description = "${var.name} transit gateway"

  # One default route table: all attachments are associated with it and
  # propagate their routes into it (full mesh connectivity).
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  dns_support                    = "enable"
  auto_accept_shared_attachments = "disable"

  tags = { Name = "${var.name}-tgw" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  tags = { Name = "${var.name}-att-${each.key}" }
}
