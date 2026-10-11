############################################
# SSM (IAM role + instance profile) - IAM is global,
# so a single role serves all instances
############################################
module "ssm" {
  source = "./module/ssm"
  name   = var.project_name
}

############################################
# VPCs
############################################

# VPC A: public subnet (jump host) + private subnet (A), Internet Gateway
module "vpc_a" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-a"
  vpc_cidr            = var.vpc_a_cidr
  availability_zone   = "${var.region}a"
  public_subnet_cidr  = var.public_subnet_a_cidr
  private_subnet_cidr = var.private_subnet_a_cidr
}

# VPC B: private subnet only
module "vpc_b" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-b"
  vpc_cidr            = var.vpc_b_cidr
  availability_zone   = "${var.region}a"
  private_subnet_cidr = var.private_subnet_b_cidr
}

# VPC C: private subnet only
module "vpc_c" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-c"
  vpc_cidr            = var.vpc_c_cidr
  availability_zone   = "${var.region}a"
  private_subnet_cidr = var.private_subnet_c_cidr
}

############################################
# Transit Gateway + 3 VPC attachments (att-a, att-b, att-c)
# Default route table: every attachment is associated with it and
# propagates its VPC CIDR into it => full connectivity A <-> B <-> C
############################################
module "tgw" {
  source = "./module/tgw"

  name = var.project_name

  attachments = {
    a = {
      vpc_id     = module.vpc_a.vpc_id
      subnet_ids = [module.vpc_a.private_subnet_id]
    }
    b = {
      vpc_id     = module.vpc_b.vpc_id
      subnet_ids = [module.vpc_b.private_subnet_id]
    }
    c = {
      vpc_id     = module.vpc_c.vpc_id
      subnet_ids = [module.vpc_c.private_subnet_id]
    }
  }
}

############################################
# VPC route tables: 10.0.0.0/8 -> Transit Gateway
# (10.x.0.0/16 stays "local" because it is more specific)
############################################
locals {
  vpc_route_tables = {
    a_public  = module.vpc_a.public_route_table_id
    a_private = module.vpc_a.private_route_table_id
    b_private = module.vpc_b.private_route_table_id
    c_private = module.vpc_c.private_route_table_id
  }
}

resource "aws_route" "to_tgw" {
  for_each = local.vpc_route_tables

  route_table_id         = each.value
  destination_cidr_block = var.tgw_summary_cidr
  transit_gateway_id     = module.tgw.transit_gateway_id

  # the attachments must be available before routes can point to the TGW
  depends_on = [module.tgw]
}

############################################
# EC2 instances (access via SSM, no SSH / no key pairs)
############################################

# Jump host: public subnet of VPC A, public IP
module "ec2_jump" {
  source = "./module/ec2"

  name                 = "${var.project_name}-jump-host"
  vpc_id               = module.vpc_a.vpc_id
  subnet_id            = module.vpc_a.public_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  associate_public_ip  = true
  allowed_ingress_cidr = [var.tgw_summary_cidr]

  depends_on = [module.vpc_a]
}

# Instance A: private subnet of VPC A
module "ec2_a" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-a"
  vpc_id               = module.vpc_a.vpc_id
  subnet_id            = module.vpc_a.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.tgw_summary_cidr]

  depends_on = [module.vpc_a]
}

# Instance B: private subnet of VPC B
module "ec2_b" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-b"
  vpc_id               = module.vpc_b.vpc_id
  subnet_id            = module.vpc_b.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.tgw_summary_cidr]

  depends_on = [module.vpc_b]
}

# Instance C: private subnet of VPC C
module "ec2_c" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-c"
  vpc_id               = module.vpc_c.vpc_id
  subnet_id            = module.vpc_c.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.tgw_summary_cidr]

  depends_on = [module.vpc_c]
}
