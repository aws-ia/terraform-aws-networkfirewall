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

variable "inspection_vpc" {
  description = "VPCs to create"
  type        = any
  default = {
    cidr_block             = "10.129.0.0/16"
    private_subnet_netmask = 28
    tgw_subnet_netmask     = 28
    number_azs             = 2
  }
}