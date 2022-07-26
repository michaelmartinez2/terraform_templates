######################################################################
#### Desired Variables
######################################################################
variable "region" {}

variable "acct_id" {
  type        = string
  description = "The account numeric id"
}

variable "company_name" {
  type    = string
  description = "The company name"
}

variable "businessunit" {
  type        = string
  description = "The business unit that owns the resources"
}

variable "compliance" {
  type        = string
  description = "A tag value describing the compliance requirements for these resources."
}

variable "environment" {
  type        = string
  description = "The environment this VPC is being deployed into (prod, dev, test, etc)"
}

variable "igwrole" {
  type        = string
  description = "The role for the IGW"
  default     = "igw"
}

variable "maptag" {
  type        = string
  description = "The tag value for the 'map-migrated' tag."
}

variable "natgwrole" {
  type        = string
  description = "The role for the NAT Gateways"
  default     = "natgw"
}

variable "rtrole" {
  type        = string
  description = "The role for the Route Tables"
  default     = "rt"
}

variable "vpcrole" {
  type        = string
  description = "The role for the VPC"
  default     = "vpc"
}

variable "vpceprole" {
  type        = string
  description = "The role for the VPC Endpoint"
  default     = "vpcep"
}

variable "platform" {
  type    = string
  description = "Used to help describe what is using the service"
  default = "demo"
}

variable "vpc_naming_prefix" {
  type    = string
  default = "${var.company_name}-${var.accountid}-${var.region}-${terraform.workspace}"
}

######################################################################
#### VPC CIDR Variables
######################################################################
variable "vpc_cidr" {
  type        = string
  default     = "xxxxxxx"
  description = "Please enter IP range (CIDR notation)"
}

######################################################################
#### Public Subnet Variables
######################################################################
variable "public_subnet1" {
  type    = string
  default = "xxxxxx"
}

variable "public_subnet2" {
  type    = string
  default = "xxxxxx"
}

variable "public_az1" {
  type    = string
  default = "xxxxxx"
}

variable "public_az2" {
  type    = string
  default = "xxxxxx"
}

######################################################################
#### Private Subnet Variables
######################################################################
variable "private_subnet1" {
  type    = string
  default = "xxxxxx"
}

variable "private_subnet2" {
  type    = string
  default = "xxxxxx"
}

variable "private_az1" {
  type    = string
  default = "xxxxxx"
}

variable "private_az2" {
  type    = string
  default = "xxxxxx"
}
