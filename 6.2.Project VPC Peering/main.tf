############################################
# SSM (IAM role + instance profile) - IAM is global,
# so a single role serves all 3 instances
############################################
module "ssm" {
  source = "./module/ssm"
  name   = var.project_name
}

############################################
# VPC-A (Mumbai): public + private subnet, Internet Gateway
############################################
module "vpc_a" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-a"
  vpc_cidr            = var.vpc_a_cidr
  availability_zone   = "${var.mumbai_region}a"
  public_subnet_cidr  = var.public_subnet_a_cidr
  private_subnet_cidr = var.private_subnet_a_cidr
}

############################################
# VPC-B (N. Virginia): private subnet only
############################################
module "vpc_b" {
  source = "./module/vpc"
  providers = {
    aws = aws.virginia
  }

  name                = "${var.project_name}-vpc-b"
  vpc_cidr            = var.vpc_b_cidr
  availability_zone   = "${var.virginia_region}a"
  private_subnet_cidr = var.private_subnet_b_cidr
}

############################################
# Inter-region VPC Peering: VPC-A <-> VPC-B
############################################
resource "aws_vpc_peering_connection" "inter" {
  vpc_id      = module.vpc_a.vpc_id
  peer_vpc_id = module.vpc_b.vpc_id
  peer_region = var.virginia_region

  tags = { Name = "${var.project_name}-inter-region" }
}

resource "aws_vpc_peering_connection_accepter" "inter" {
  provider                  = aws.virginia
  vpc_peering_connection_id = aws_vpc_peering_connection.inter.id
  auto_accept               = true

  tags = { Name = "${var.project_name}-inter-region-accepter" }
}

############################################
# Peering routes (private subnet of VPC-A <-> private subnet of VPC-B)
# EC2-B <-> EC2-C (green arrow in the diagram)
############################################

# VPC-A private route table -> VPC-B private subnet
resource "aws_route" "a_private_to_b_private" {
  route_table_id            = module.vpc_a.private_route_table_id
  destination_cidr_block    = var.private_subnet_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.inter.id

  depends_on = [aws_vpc_peering_connection_accepter.inter]
}

# VPC-B private route table -> VPC-A private subnet (return path)
resource "aws_route" "b_private_to_a_private" {
  provider                  = aws.virginia
  route_table_id            = module.vpc_b.private_route_table_id
  destination_cidr_block    = var.private_subnet_a_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.inter.id

  depends_on = [aws_vpc_peering_connection_accepter.inter]
}

############################################
# EC2 instances (access via SSM, no SSH / no key pairs)
############################################

# EC2-A: public subnet, public IP
module "ec2_a" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-a"
  vpc_id               = module.vpc_a.vpc_id
  subnet_id            = module.vpc_a.public_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  associate_public_ip  = true
  allowed_ingress_cidr = [var.vpc_a_cidr]

  depends_on = [module.vpc_a]
}

# EC2-B: private subnet of VPC-A
module "ec2_b" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-b"
  vpc_id               = module.vpc_a.vpc_id
  subnet_id            = module.vpc_a.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.vpc_a_cidr, var.vpc_b_cidr]

  depends_on = [module.vpc_a]
}

# EC2-C: private subnet of VPC-B (N. Virginia)
module "ec2_c" {
  source = "./module/ec2"
  providers = {
    aws = aws.virginia
  }

  name                 = "${var.project_name}-ec2-c"
  vpc_id               = module.vpc_b.vpc_id
  subnet_id            = module.vpc_b.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.vpc_a_cidr, var.vpc_b_cidr]

  depends_on = [module.vpc_b]
}
