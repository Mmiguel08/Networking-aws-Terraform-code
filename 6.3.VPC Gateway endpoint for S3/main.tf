data "aws_caller_identity" "current" {}

############################################
# S3 bucket (target of the gateway endpoint)
############################################
module "s3" {
  source      = "./module/s3"
  bucket_name = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.region}"
}

############################################
# SSM (IAM role + instance profile) + S3 access for the instances
############################################
module "ssm" {
  source         = "./module/ssm"
  name           = var.project_name
  s3_bucket_arns = [module.s3.bucket_arn]
}

############################################
# VPC-A: public + private subnet, Internet Gateway,
# SSM interface endpoints and S3 gateway endpoint
############################################
module "vpc" {
  source = "./module/vpc"

  name                       = "${var.project_name}-vpc-a"
  vpc_cidr                   = var.vpc_cidr
  availability_zone          = "${var.region}a"
  public_subnet_cidr         = var.public_subnet_cidr
  private_subnet_cidr        = var.private_subnet_cidr
  enable_s3_gateway_endpoint = var.enable_s3_gateway_endpoint
}

############################################
# EC2 instances (access via SSM, no SSH / no key pairs)
############################################

# EC2-A: public subnet, public IP
module "ec2_a" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-a"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  associate_public_ip  = true
  allowed_ingress_cidr = [var.vpc_cidr]

  depends_on = [module.vpc]
}

# EC2-B: private subnet, reaches S3 only through the gateway endpoint
module "ec2_b" {
  source = "./module/ec2"

  name                 = "${var.project_name}-ec2-b"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_subnet_id
  instance_type        = var.instance_type
  instance_profile     = module.ssm.instance_profile_name
  allowed_ingress_cidr = [var.vpc_cidr]

  depends_on = [module.vpc]
}
