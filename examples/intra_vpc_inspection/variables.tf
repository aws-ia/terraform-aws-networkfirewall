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
    cidr_block = "10.129.0.0/16"
    number_azs = 2
    private_subnet_cidrs = {
      private1 = ["10.129.0.0/24", "10.129.1.0/24", "10.129.2.0/24"]
      private2 = ["10.129.3.0/24", "10.129.4.0/24", "10.129.5.0/24"]
      private3 = ["10.129.6.0/24", "10.129.7.0/24", "10.129.8.0/24"]
    }
    firewall_subnet_cidrs = ["10.129.9.0/28", "10.129.9.16/28", "10.129.9.32/28"]
    endpoint_subnet_cidrs = ["10.129.9.48/28", "10.129.9.64/28", "10.129.9.80/28"]
    instance_type         = "t2.micro"
  }
}

