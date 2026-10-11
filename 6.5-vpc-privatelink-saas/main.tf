data "aws_caller_identity" "current" {}

############################################
# SSM (IAM role + instance profile) - IAM is global,
# so a single role serves all 3 instances
############################################
module "ssm" {
  source = "./module/ssm"
  name   = var.project_name
}

############################################
# VPC-A (Service Consumer): public + private subnet, Internet Gateway
############################################
module "vpc_a" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-a"
  vpc_cidr            = var.vpc_a_cidr
  availability_zone   = "${var.region}a"
  public_subnet_cidr  = var.public_subnet_a_cidr
  private_subnet_cidr = var.private_subnet_a_cidr
}

############################################
# VPC-B (Service Provider): two private subnets only (no IGW, no NAT)
############################################
module "vpc_b" {
  source = "./module/vpc"

  name                         = "${var.project_name}-vpc-b"
  vpc_cidr                     = var.vpc_b_cidr
  availability_zone            = "${var.region}a"
  private_subnet_cidr          = var.nlb_subnet_b_cidr
  secondary_private_subnet_cidr = var.app_subnet_b_cidr
}

############################################
# Service Provider: EC2-C (the "SaaS" app) behind an NLB,
# published as a VPC Endpoint Service (PrivateLink)
############################################
module "ec2_c" {
  source = "./module/ec2"

  name             = "${var.project_name}-ec2-c"
  vpc_id           = module.vpc_b.vpc_id
  subnet_id        = module.vpc_b.secondary_private_subnet_id
  instance_type    = var.instance_type
  instance_profile = module.ssm.instance_profile_name
  user_data        = file("${path.root}/assets/saas_app.sh")

  # The NLB talks to the instance from its own subnet (client IP preservation is off)
  tcp_ingress = [
    {
      port  = var.service_port
      cidrs = [var.nlb_subnet_b_cidr]
    }
  ]

  depends_on = [module.vpc_b]
}

module "privatelink_provider" {
  source = "./module/privatelink_provider"

  name                = var.project_name
  vpc_id              = module.vpc_b.vpc_id
  nlb_subnet_ids      = [module.vpc_b.private_subnet_id]
  target_instance_id  = module.ec2_c.instance_id
  port                = var.service_port
  allowed_principals  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

############################################
# Service Consumer: interface endpoint (ENI) to the service
############################################
module "privatelink_consumer" {
  source = "./module/privatelink_consumer"

  name         = var.project_name
  vpc_id       = module.vpc_a.vpc_id
  vpc_cidr     = var.vpc_a_cidr
  subnet_ids   = [module.vpc_a.private_subnet_id]
  service_name = module.privatelink_provider.service_name
  port         = var.service_port
}

############################################
# Consumer instances (access via SSM, no SSH / no key pairs)
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

# EC2-B: private subnet, consumes the service through the PrivateLink endpoint
module "ec2_b" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-b"
  vpc_id               = module.vpc_a.vpc_id
  subnet_id            = module.vpc_a.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.vpc_a_cidr]

  depends_on = [module.vpc_a]
}
