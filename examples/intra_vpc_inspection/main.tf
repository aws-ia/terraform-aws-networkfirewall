# --- examples/intra_vpc_inspection/main.tf ---

# AWS Network Firewall
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "1.0.0"

  network_firewall_name        = "anfw-${var.identifier}"
  network_firewall_description = "AWS Network Firewall - ${var.identifier}"
  network_firewall_policy      = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.vpc.vpc_attributes.id
  number_azs  = var.vpc.number_azs
  vpc_subnets = { for k, v in module.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "inspection" }

  routing_configuration = {
    intra_vpc_inspection = {
      number_routes = 6
      routes = [
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private1" }
          destination_subnet_cidr_blocks = local.private2_cidrs
        },
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private2" }
          destination_subnet_cidr_blocks = local.private1_cidrs
        },
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private1" }
          destination_subnet_cidr_blocks = local.private3_cidrs
        },
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private3" }
          destination_subnet_cidr_blocks = local.private1_cidrs
        },
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private2" }
          destination_subnet_cidr_blocks = local.private3_cidrs
        },
        {
          source_subnet_route_tables     = { for k, v in module.vpc.rt_attributes_by_type_by_az.private : split("/", k)[1] => v.id if split("/", k)[0] == "private3" }
          destination_subnet_cidr_blocks = local.private2_cidrs
        }
      ]
    }
  }
}

# VPC Module - https://github.com/aws-ia/terraform-aws-vpc
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 4.3.0"

  name       = "vpc_intra_inspection"
  cidr_block = var.vpc.cidr_block
  az_count   = var.vpc.number_azs

  subnets = {
    private1   = { cidrs = var.vpc.private1_subnet_cidrs }
    private2   = { cidrs = var.vpc.private2_subnet_cidrs }
    private3   = { cidrs = var.vpc.private3_subnet_cidrs }
    inspection = { cidrs = var.vpc.inspection_subnet_cidrs }
  }
}

# Local variables - creating maps of subnet CIDRs. Format: AZ --> CIDR block
locals {
  private1_cidrs = tomap({
    for i, az in module.vpc.azs : az => var.vpc.private1_subnet_cidrs[i]
  })
  private2_cidrs = tomap({
    for i, az in module.vpc.azs : az => var.vpc.private2_subnet_cidrs[i]
  })
  private3_cidrs = tomap({
    for i, az in module.vpc.azs : az => var.vpc.private3_subnet_cidrs[i]
  })
}


