# --- examples/central_inspection_without_egress/variables.tf ---

variable "aws_region" {
  description = "AWS Region."
  type        = string

  default = "us-west-1"
}

variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "central-inspection"
}

variable "vpcs" {
  description = "VPCs to create"
  type        = any
  default = {

    "inspection-vpc" = {
      type                   = "inspection"
      cidr_block             = "10.129.0.0/16"
      private_subnet_netmask = 28
      tgw_subnet_netmask     = 28
      number_azs             = 2
    }

    "spoke-vpc-1" = {
      type                   = "spoke"
      cidr_block             = "10.0.0.0/16"
      private_subnet_netmask = 28
      tgw_subnet_netmask     = 28
      number_azs             = 2
      instance_type          = "t2.micro"
    }

    "spoke-vpc-2" = {
      type                   = "spoke"
      cidr_block             = "10.1.0.0/16"
      private_subnet_netmask = 24
      tgw_subnet_netmask     = 28
      number_azs             = 2
      instance_type          = "t2.micro"
    }

    "spoke-vpc-3" = {
      type                   = "spoke"
      cidr_block             = "10.2.0.0/16"
      private_subnet_netmask = 24
      tgw_subnet_netmask     = 28
      number_azs             = 2
      instance_type          = "t2.micro"
    }
  }
}