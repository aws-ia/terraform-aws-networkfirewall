# --- examples/central_inspection_with_egress/variables.tf ---

variable "aws_region" {
  description = "AWS Region."
  type        = string

  default = "eu-west-1"
}

variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "central-inspection-egress"
}

variable "supernet" {
  description = "Supernet CIDR block."
  type        = string

  default = "10.0.0.0/8"
}

variable "inspection_vpc" {
  description = "VPCs to create"
  type        = any
  default = {
    cidr_block             = "10.129.0.0/16"
    public_subnet_netmask  = 28
    private_subnet_netmask = 28
    tgw_subnet_netmask     = 28
    number_azs             = 2
  }
}