############################################
# SQS queue (target of the interface endpoint)
############################################
module "sqs" {
  source     = "./module/sqs"
  queue_name = "${var.project_name}-queue"
}

############################################
# SSM (IAM role + instance profile) + SQS access for the instances
############################################
module "ssm" {
  source         = "./module/ssm"
  name           = var.project_name
  sqs_queue_arns = [module.sqs.queue_arn]
}

############################################
# VPC-A: public + private subnet, Internet Gateway,
# SSM interface endpoints and SQS interface endpoint
############################################
module "vpc" {
  source = "./module/vpc"

  name                = "${var.project_name}-vpc-a"
  vpc_cidr            = var.vpc_cidr
  availability_zone   = "${var.region}a"
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  enable_sqs_endpoint = var.enable_sqs_interface_endpoint
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

# EC2-B: private subnet, reaches SQS only through the interface endpoint
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
