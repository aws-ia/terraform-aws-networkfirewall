# --- examples/central_inspection_with_egress/main.tf ---

# AWS Network Firewall
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "1.0.0"

  network_firewall_name        = "anfw-${var.identifier}"
  network_firewall_description = "AWS Network Firewall - ${var.identifier}"
  network_firewall_policy      = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.inspection_vpc.vpc_attributes.id
  number_azs  = var.inspection_vpc.number_azs
  vpc_subnets = { for k, v in module.inspection_vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "inspection" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      connectivity_subnet_route_tables = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.transit_gateway : k => v.id }
      public_subnet_route_tables       = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks              = [var.supernet]
    }
  }
}

# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway - ${var.identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "tgw-${var.identifier}"
  }
}

# Inspection VPC. Module - https://github.com/aws-ia/terraform-aws-vpc
module "inspection_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 4.3.0"

  name       = "inspection_vpc"
  cidr_block = var.inspection_vpc.cidr_block
  az_count   = var.inspection_vpc.number_azs

  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  transit_gateway_routes = {
    inspection = var.supernet
  }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    inspection = {
      netmask                 = var.inspection_vpc.inspection_subnet_netmask
      connect_to_public_natgw = true
    }
    transit_gateway = {
      netmask                                         = var.inspection_vpc.tgw_subnet_netmask
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "enable"
    }
  }
}

