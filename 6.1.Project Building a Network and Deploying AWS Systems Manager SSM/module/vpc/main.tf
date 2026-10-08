# Create local variables to store the number of public and private subnets
locals {
  num_of_puiblic_subnets = length(var.vpc_config.availability_zones)
  num_of_private_subnets = length(var.vpc_config.availability_zones)
}

# Data source to get the current region
data "aws_region" "current" {}

############## VPC ###############

#Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_config.cidr_block
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  enable_dns_support = var.vpc_config.enable_dns_support
  tags = var.vpc_config.tags
}

#Create an Internet Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "ashelga-igw"
  }
}

# Create public Subnets
resource "aws_subnet" "public" {
  count = local.num_of_puiblic_subnets
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.vpc_config.availability_zones[count.index]
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index + 1)
  tags = {
    "name" = "ashelga-public-sub_${count.index + 1}"
  }
}


# Create a route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Associate the route table with public subnets
resource "aws_route_table_association" "public" {
  count = local.num_of_puiblic_subnets
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Private Subnets
resource "aws_subnet" "private" {
    count = local.num_of_private_subnets
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.vpc_config.availability_zones[count.index]
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + 1)
    tags = {
      "Name" = "ashelga-private-sub_${count.index + 1}"
    }
}

#create route tables for each private
resource "aws_route_table" "private" {
  count = local.num_of_private_subnets
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }
}

# Associate the route tables with private subnets
resource "aws_route_table_association" "private" {
  count = local.num_of_private_subnets
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

#Create an Elastic IP for each NAT Gateway
resource "aws_eip" "ngw" {
  count = local.num_of_private_subnets
  tags = {
    "Name" = "ashelga_nat_gateway_${count.index + 1}"
  }
}

#Create a NAT Gateway for each public subnet
resource "aws_nat_gateway" "ngw" {
  count = local.num_of_private_subnets
  allocation_id = element(aws_eip.ngw[*].id, count.index)
  subnet_id = element(aws_subnet.public[*].id, count.index)
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    "Name" = "ashelga_nat_gateway_${count.index + 1}"
  }
}