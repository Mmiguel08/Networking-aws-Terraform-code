#get current region
data "aws_region" "current" {}

################ Create VPC Network ##################
module "networking" {
  source = "./module/vpc"

  vpc_config = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    availability_zones   = ["ap-south-1a"]

    tags = {
      "Name" = "Ashelga-VPC"
    }
  }
}

############## Creating SSM ############################
module "ssm" {
  source = "./module/ssm"
}

################# Create VPC Endpoints ##################
resource "aws_vpc_endpoint" "vpc_endpoints" {
  for_each            = toset(var.vpc_endpoints)
  vpc_id              = module.networking.vpc_resources.vpc_id
  subnet_ids          = module.networking.vpc_resources.private_subnet_ids
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce_security_groups.id]

  tags = {
    "Name" = "ashelga_vpc_endpoint_${each.key}"
  }
}


########## Create VPC Endpoint Security Group and Associated Rules #########
resource "aws_security_group" "vpce_security_groups" {
  vpc_id      = module.networking.vpc_resources.vpc_id
  name        = "VPC Endpoints for SSM"
  description = " Allow Inbount HTTPS traffic to VPC Endpoints"
}

resource "aws_security_group_rule" "vpce_ingress_itself" {
  type                     = "ingress"
  description              = "Allow HTTPS traffic from ec2"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce_security_groups.id
  source_security_group_id = aws_security_group.vpce_security_groups.id
}

resource "aws_security_group_rule" "vpce_ingress_ec2" {
  type                     = "ingress"
  description              = "Allow HTTPS traffic from ec2"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce_security_groups.id
  source_security_group_id = aws_security_group.ssm_ec2.id
}

############ Create EC2 ##############

module "ec2_public1" {
  source = "./module/ec2"
  ec2_config = {
    instance_type     = "t3.micro"
    subnet_id         = module.networking.vpc_resources.private_subnet_ids[0]
    security_group_id = [aws_security_group.ssm_ec2.id]
    public_ip         = true
    tags = {
      "Name" = "ashelga_ec2_public_1"
    }
  }
}

module "ec2_private1" {
  source = "./module/ec2"
  ec2_config = {
    instance_type     = "t3.micro"
    subnet_id         = module.networking.vpc_resources.private_subnet_ids[0]
    security_group_id = [aws_security_group.ssm_ec2.id]
    tags = {
      "Name" = "ashelga_ec2_private_1"
    }
  }
}

########## Create EC2 Security Group and Associated Rules ##########
resource "aws_security_group" "ssm_ec2" {
  vpc_id      = module.networking.vpc_resources.vpc_id
  name        = "Allow SSm for EC2"
  description = "Allow EC2 HTTPS traffic to SSM VPC Endpoints"
}

resource "aws_security_group_rule" "ssm_ec2" {
  type                     = "egress"
  description              = "Allow EC2 HTTPS traffic to SSM VPC Endpoint SG"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ssm_ec2.id
  source_security_group_id = aws_security_group.vpce_security_groups.id
}


