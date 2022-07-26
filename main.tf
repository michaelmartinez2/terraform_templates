# Simple VPC with 
# 2 Public Subnets, 2 Private Subnets 
# 1 Public RT, and 2 Private RT
# 2 EIPs
# 2 Nat Gateways
# 1 Internet Gateway

######################################################
###Backend setup
######################################################
terraform {
  backend "s3" {
    key = "vpc.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

######################################################
####Outputs from main.tf
######################################################
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "env:/dev/vpc.tfstate"
    region = var.region
  }
}


######################################################
#### VPC CIDR
######################################################
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.vpc_naming_prefix}"
  }
}

######################################################
#### Public Subnets
######################################################
resource "aws_subnet" "pub_sub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet1
  availability_zone = "xxxxxxx"

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-AZ1"
  }
}

resource "aws_subnet" "pub_sub2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet2
  availability_zone = "xxxxxxx"

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-AZ2"
  }
}

######################################################
#### Private Subnets
######################################################
resource "aws_subnet" "priv_sub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.AppSubnet1
  availability_zone = "xxxxxxx"

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-AZ1"
  }
}

resource "aws_subnet" "priv_sub2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.AppSubnet2
  availability_zone = "xxxxxxx"

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-AZ2"
  }
}


######################################################
#### Internet Gateway
######################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.miketechvpc.id

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-igw"
  }
}

######################################################
#### Elastic IPs
######################################################
resource "aws_eip" "eip1" {
  vpc = true

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-eip-natgw-AZ1"
  }
}

resource "aws_eip" "eip2" {
  vpc = true

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-eip-natgw-AZ2"
  }
}

######################################################
#### Nat Gateways
######################################################
resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.pub_sub1.id

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-natgw-AZ1"
  }
}

resource "aws_nat_gateway" "natgw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.pub_sub2.id

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-natgw-AZ2"
  }
}

######################################################
#### Route Tables Public
######################################################
resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.miketechvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-pub-rt"
  }
}

resource "aws_route_table_association" "pubrtassoc1" {
  subnet_id      = aws_subnet.pub_sub1.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table_association" "pubrtassoc2" {
  subnet_id      = aws_subnet.pub_sub2.id
  route_table_id = aws_route_table.pubrt.id
}


######################################################
#### Route Tables Private
######################################################
resource "aws_route_table" "privrt1" {
  vpc_id = aws_vpc.miketechvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw1.id
  }

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-pub-rt1"
  }
}

resource "aws_route_table_association" "privrtassoc1" {
  subnet_id      = aws_subnet.priv_sub1.id
  route_table_id = aws_route_table.privrt1.id
}

resource "aws_route_table" "privrt2" {
  vpc_id = aws_vpc.miketechvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw2.id
  }

  tags = {
    Name = "${var.vpc_naming_prefix}-${terraform.workspace}-pub-rt2"
  }
}

resource "aws_route_table_association" "privrtassoc2" {
  subnet_id      = aws_subnet.priv_sub2.id
  route_table_id = aws_route_table.privrt2.id
}
