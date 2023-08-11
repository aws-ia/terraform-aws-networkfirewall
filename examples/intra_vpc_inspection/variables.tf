# --- examples/intra_vpc_inspection/variables.tf ---

variable "aws_region" {
  description = "AWS Region."
  type        = string

  default = "eu-west-2"
}

variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "intra-vpc-inspection"
}

variable "vpc" {
  description = "Information about the VPC to create."
  type        = any
  default = {
    cidr_block              = "10.129.0.0/16"
    number_azs              = 2
    private1_subnet_cidrs   = ["10.129.0.0/24", "10.129.1.0/24"]
    private2_subnet_cidrs   = ["10.129.2.0/24", "10.129.3.0/24"]
    private3_subnet_cidrs   = ["10.129.4.0/24", "10.129.5.0/24"]
    inspection_subnet_cidrs = ["10.129.6.0/28", "10.129.6.16/28"]
  }
}

