terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Internal Network Load Balancer in front of the service
resource "aws_lb" "this" {
  name               = "${var.name}-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = var.nlb_subnet_ids

  tags = { Name = "${var.name}-nlb" }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  # With PrivateLink the target sees the NLB node IP as source anyway.
  # Keeping this off makes the security group rule predictable (NLB subnet CIDR).
  preserve_client_ip = "false"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = { Name = "${var.name}-tg" }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_id
  port             = var.port
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Publishes the NLB as a PrivateLink service (the "SaaS application")
resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [aws_lb.this.arn]
  allowed_principals         = var.allowed_principals

  tags = { Name = "${var.name}-endpoint-service" }

  depends_on = [aws_lb_listener.this]
}
