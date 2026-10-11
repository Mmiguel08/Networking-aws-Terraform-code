terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Latest Amazon Linux 2023 AMI (SSM Agent and AWS CLI preinstalled)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SG for ${var.name} instance (no SSH - access via SSM)"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_ingress_cidr) > 0 ? [1] : []
    content {
      description = "ICMP from allowed CIDRs"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = var.allowed_ingress_cidr
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = var.instance_profile

  associate_public_ip_address = var.associate_public_ip

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
  }

  tags = { Name = "${var.name}-ec2" }
}
