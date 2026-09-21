# -------------------------------Creation of AWS Virtual private Cloud------------------------
resource "aws_vpc" "ashelga_vpc" {
  cidr_block       = "172.17.0.0/16"
  instance_tenancy = "default"
  region           = var.aws_region

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ashelga_vpc"
  }
}
#-----------------------------------Creating Internet Gateway ------------------------------
resource "aws_internet_gateway" "ashelga_igw" {
  vpc_id = aws_vpc.ashelga_vpc.id
  tags = {
    Name = "ashelga_igw"
  }
}

#-----------------------------------Creating Subnets ---------------------------------------
resource "aws_subnet" "ashelga_sub_public_1" {
  vpc_id                  = aws_vpc.ashelga_vpc.id
  cidr_block              = "172.17.0.0/24"
  availability_zone       = var.az_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "ashelga_sub_public_1"
  }
}

resource "aws_subnet" "ashelga_sub_public_2" {
  vpc_id                  = aws_vpc.ashelga_vpc.id
  cidr_block              = "172.17.2.0/24"
  availability_zone       = var.az_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "ashelga_sub_public_2"
  }
}

resource "aws_subnet" "ashelga_sub_private_1" {
  vpc_id            = aws_vpc.ashelga_vpc.id
  availability_zone = var.az_zone
  cidr_block        = "172.17.1.0/24"

  tags = {
    Name = "ashelga_sub_private_1"
  }
}
#---------------------------------------Creating Elastic IP ------------------------------------------------
resource "aws_eip" "ashelga_nat_gateway_eip" {
  domain = "vpc"
  tags = {
    Name = "ashelga_nat_gateway_eip"
  }
}
#--------------------------------------  Creating NAT Gateway ----------------------------------------------
resource "aws_nat_gateway" "ashelga_nat_gateway" {
  allocation_id = aws_eip.ashelga_nat_gateway_eip.id
  subnet_id     = aws_subnet.ashelga_sub_public_2.id

  tags = {
    Name = "ashelga_nat_gateway"
  }
  depends_on = [aws_internet_gateway.ashelga_igw]
}
#----------------------------------------Creating Route tables--------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ashelga_vpc.id
  route {
    cidr_block = "172.17.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ashelga_igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ashelga_vpc.id

  route {
    cidr_block = "172.17.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ashelga_nat_gateway.id
  }

  tags = {
    Name = "private_rt"
  }
}

#-----------------------------------Subnet association ---------------------------------------
resource "aws_route_table_association" "ashelga_sub_public_association_1" {
  subnet_id      = aws_subnet.ashelga_sub_public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "ashelga_sub_public_association_2" {
  subnet_id      = aws_subnet.ashelga_sub_public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "ashelga_sub_private_association_1" {
  subnet_id      = aws_subnet.ashelga_sub_private_1.id
  route_table_id = aws_route_table.private_rt.id
}
#---------------------------------------Creation of security Groups-----------------------------------------
resource "aws_security_group" "ashelga_public_ec2-sg" {
  name        = "ashelga_public_ec2-sg"
  description = "Security group for Instance in Public subnet-1"
  vpc_id      = aws_vpc.ashelga_vpc.id

  tags = {
    Name = "ashelga_public_ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ashelga_public_ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_sub_public_out_traffic" {
  security_group_id = aws_security_group.ashelga_public_ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}


resource "aws_security_group" "ashelga_private_ec2-sg" {
  name        = "ashelga_private_ec2-sg"
  description = "Security group for Instance in Private subnet-1"
  vpc_id      = aws_vpc.ashelga_vpc.id

  tags = {
    Name = "ashelga_private_ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_ec2_1" {
  security_group_id = aws_security_group.ashelga_private_ec2-sg.id
  cidr_ipv4         = "172.17.0.0/16"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_sub_private_out_traffic" {
  security_group_id = aws_security_group.ashelga_private_ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

#--------------------------------Creating AWS EC2 Instances --------------------------------
#Getting the most recent iam
data "aws_ami" "amz-linux-2023-ami" {
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
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "ashelga_ec2_public" {
  ami           = data.aws_ami.amz-linux-2023-ami.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.ashelga_sub_public_1.id
  vpc_security_group_ids = [
    aws_security_group.ashelga_public_ec2-sg.id
  ]
  associate_public_ip_address = true
  tags = {
    Name = "ashelga-ec2-public"
  }
}

resource "aws_instance" "ashelga_ec2_private" {
  ami           = data.aws_ami.amz-linux-2023-ami.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.ashelga_sub_private_1.id
  key_name      = var.aws_key_pair
  vpc_security_group_ids = [
    aws_security_group.ashelga_private_ec2-sg.id
  ]
  tags = {
    Name = "ashelga-ec2-private"
  }
}