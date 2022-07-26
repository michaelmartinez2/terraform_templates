######################################################################
#### Desired Variables
######################################################################
variable "region" {}

variable "platform" {
  type    = string
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
