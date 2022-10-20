# --- examples/single_vpc/variables.tf ---

variable "aws_region" {
  description = "AWS Region."
  type        = string

  default = "us-east-2"
}

variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "single-vpc"
}

variable "vpc" {
  description = "Information about the VPC to create."
  type        = any
  default = {
    cidr_block             = "10.129.0.0/16"
    number_azs             = 2
    firewall_subnet_cidrs  = ["10.129.0.0/24", "10.129.1.0/24", "10.129.2.0/24"]
    protected_subnet_cidrs = ["10.129.3.0/24", "10.129.4.0/24", "10.129.5.0/24"]
    private_subnet_cidrs   = ["10.129.6.0/24", "10.129.7.0/24", "10.129.8.0/24"]
  }
}

