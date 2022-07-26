terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.0"
   }
 }
}

provider "aws" {
  profile = "RS_STS"
  region  = "us-west-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

### AWS VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_range}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.vpcrole}"
  }
}

### Internet Gateway
resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-igw"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    map-migrated = "${var.maptag}"
    owner        = "${var.owner}"
    role         = "${var.igwrole}"
  }
}

### S3 Endpoint
resource "aws_vpc_endpoint" "s3endpoint" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-ep-s3"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    map-migrated = "${var.maptag}"
    owner        = "${var.owner}"
    role         = "${var.vpceprole}"
  }
}

### Public Subnets
# Loop over this as many times as necessary to create the correct number of Public Subnets
resource "aws_subnet" "public_subnet" {
  count             = "${var.availability_zones_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.subnet_cidr_public, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-pub-AZ${count.index + 1}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.subnetrole}"    
  }
}

### App Subnets
# Loop over this as many times as necessary to create the correct number of Private Subnets
resource "aws_subnet" "app_subnet" {
  count             = "${var.availability_zones_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.subnet_cidr_app, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-app-AZ${count.index + 1}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.subnetrole}"    
  }
}

### DB Subnets
# Loop over this as many times as necessary to create the correct number of Private Subnets
resource "aws_subnet" "db_subnet" {
  count             = "${var.availability_zones_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.subnet_cidr_db, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-db-AZ${count.index + 1}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.subnetrole}"    
  }
}

### Elastic IPs
# Need one per AZ for the NAT Gateways
resource "aws_eip" "nat_gw_eip" {
  count = "${var.availability_zones_count}"
  vpc   = true

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-eip-natgw-AZ${count.index + 1}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    map-migrated = "${var.maptag}"
    owner        = "${var.owner}"
    role         = "${var.igwrole}"
  }
}

### NAT Gateways
# Loops as necessary to create one per AZ in the Public Subnets, and associate the provisioned Elastic IP
resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat_gw_eip.*.id, count.index)}"
  count         = "${var.availability_zones_count}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-natgw-AZ${count.index + 1}"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    map-migrated = "${var.maptag}"
    owner        = "${var.owner}"
    role         = "${var.natgwrole}"
  }
}

### App Subnet Route Tables
# Routes traffic destined for `0.0.0.0/0` to the NAT Gateway in the same AZ
resource "aws_route_table" "route_table_app" {
  count  = "${var.availability_zones_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-app-rt"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.rtrole}"
  }
}

### App Subnet Route Table Associations
resource "aws_route_table_association" "app_subnet_assocation" {
  count          = "${var.availability_zones_count}"
  subnet_id      = "${element(aws_subnet.app_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.route_table_app.*.id, count.index)}"
}

### S3 VPC endpoint route table association
resource "aws_vpc_endpoint_route_table_association" "apps3endpointrtassoc" {
  count           = "${var.availability_zones_count}"
  route_table_id  = "${element(aws_route_table.route_table_app.*.id, count.index)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3endpoint.id}"
}

### DB Subnet Route Table
# Routes traffic destined for `0.0.0.0/0` not allowed
resource "aws_route_table" "route_table_db" {
  vpc_id = "${aws_vpc.vpc.id}"

  route = []

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-db-rt"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.rtrole}"
  }
}

### DB Subnet Route Table Associations
resource "aws_route_table_association" "db_subnet_assocation" {
  count          = "${var.availability_zones_count}"
  subnet_id      = "${element(aws_subnet.db_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table_db.id}"
}

### S3 VPC endpoint route table association
resource "aws_vpc_endpoint_route_table_association" "dbs3endpointrtassoc" {
  route_table_id  = "${aws_route_table.route_table_db.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3endpoint.id}"
}

### Public Route Tables
# Routes traffic destined for `0.0.0.0/0` to the Internet Gateway for the VPC
resource "aws_route_table" "route_table_pub" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags = {
    Name         = "${var.companyid}-${var.accountid}-${var.region}-${var.environment}-pub-rt"
    environment  = "${var.environment}"
    businessunit = "${var.businessunit}"
    compliance   = "${var.compliance}"
    owner        = "${var.owner}"
    role         = "${var.rtrole}"
  }
}

### Public Route Table Associations
resource "aws_route_table_association" "pub_subnet_assocation" {
  count          = "${var.availability_zones_count}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table_pub.id}"
}