# The account id
variable "accountid" {
  type        = string
  description = "The account id"
}

# Number of AZs to create
variable "availability_zones_count" {
  default     = "2"
  type        = string
  description = "Number of Availability Zones to use"
}

# Name of the business unit that owns the resources.
variable "businessunit" {
  type        = string
  description = "The business unit that owns the resources"
}

# The abbreviated name of the company
variable "companyid" {
  type        = string
  description = "The abbreviated name of the company"
}

# The compliance requirements of these resources.
variable "compliance" {
  type        = string
  description = "A tag value describing the compliance requirements for these resources."
}

# Descriptive name of the Environment to add to tags (should make sense to humans)
variable "environment" {
  type        = string
  description = "The environment this VPC is being deployed into (prod, dev, test, etc)"
}

# The role for the IGW.
variable "igwrole" {
  type        = string
  description = "The role for the IGW"
  default     = "igw"
}

# The tag value for the 'map-migrated' tag.
variable "maptag" {
  type        = string
  description = "The tag value for the 'map-migrated' tag."
}

# The role for the NAT Gateways.
variable "natgwrole" {
  type        = string
  description = "The role for the NAT Gateways"
  default     = "natgw"
}

# The name of the owner of these resources.
variable "owner" {
  type        = string
  description = "The name of the owner of these resources."
}

# The region the resources will be created in.
variable "region" {
  type        = string
  description = "The region the resources will be created in."
}

# The role for the route tables.
variable "rtrole" {
  type        = string
  description = "The role for the Route Tables"
  default     = "rt"
}

# The role for the VPC.
variable "vpcrole" {
  type        = string
  description = "The role for the VPC"
  default     = "vpc"
}

# The role for the VPC Endpoint.
variable "vpceprole" {
  type        = string
  description = "The role for the VPC Endpoint"
  default     = "vpcep"
}

# The CIDR Range for the entire VPC
variable "vpc_cidr_range" {
  default     = "172.18.0.0/16"
  type        = string
  description = "The IP Address space used for the VPC in CIDR notation."
}

# The CIDR Ranges for the Public Subnets
variable "subnet_cidr_public" {
  type        = list(string)
  description = "IP Address Ranges in CIDR Notation for Public Subnets in AZ1-2."
  default     = ["172.18.0.0/24", "172.18.1.0/24"]
}

# The CIDR Ranges for the App Subnets
variable "subnet_cidr_app" {
  type        = list(string)
  default     = ["172.18.2.0/24", "172.18.3.0/24"]
  description = "IP Address Ranges in CIDR Notation for App Subnets in AZ 1-2."
}

# The CIDR Ranges for the DB Subnets
variable "subnet_cidr_db" {
  type        = list(string)
  default     = ["172.18.4.0/24", "172.18.5.0/24"]
  description = "IP Address Ranges in CIDR Notation for DB Subnets in AZ 1-2."
}

# The role for all subnets
variable "subnetrole" {
  type        = string
  description = "The role for all subnets"
  default     = "subnet"
}

# TransitVPC enabled
variable "transit_vpc" {
  type        = bool
  default     = "false"
  description = "Enable TransitVPC on this VGW"
}
