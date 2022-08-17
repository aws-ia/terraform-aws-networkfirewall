# --- examples/central_inspection_with_egress/main.tf ---

# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway - ${var.identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "tgw-${var.identifier}"
  }
}

# INSPECTION VPC AND AWS NETWORK FIREWALL RESOURCE
# Inspection VPC. Module - https://github.com/aws-ia/terraform-aws-vpc
module "inspection_vpc" {
  for_each = {
    for k, v in var.vpcs : k => v
    if v.type == "inspection"
  }
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    public = {
      name_prefix               = "public"
      netmask                   = each.value.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }

    private = {
      name_prefix              = "inspection"
      netmask                  = each.value.private_subnet_netmask
      route_to_nat             = true
      route_to_transit_gateway = [var.supernet]
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      netmask                                         = each.value.tgw_subnet_netmask
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "enable"
    }
  }
}

# AWS Network Firewall
module "network_firewall" {
  source = "../.."

  network_firewall_name   = "anfw-${var.identifier}"
  network_firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.inspection_vpc["inspection-vpc"].vpc_attributes.id
  number_azs  = var.vpcs["inspection-vpc"].number_azs
  vpc_subnets = { for k, v in module.inspection_vpc["inspection-vpc"].private_subnet_attributes_by_az : k => v.id }

  routing_configuration = {
    centralized_inspection_with_egress = {
      tgw_subnet_route_tables    = { for k, v in module.inspection_vpc["inspection-vpc"].route_table_attributes_by_type_by_az.transit_gateway : k => v.id }
      public_subnet_route_tables = { for k, v in module.inspection_vpc["inspection-vpc"].route_table_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks        = values({ for k, v in var.vpcs : k => v.cidr_block if v.type == "spoke" })
    }
  }
}

# SPOKE VPCs. Module - https://github.com/aws-ia/terraform-aws-vpc
module "spoke_vpcs" {
  for_each = {
    for k, v in var.vpcs : k => v
    if v.type == "spoke"
  }
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    private = {
      name_prefix              = "private"
      netmask                  = each.value.private_subnet_netmask
      route_to_nat             = false
      route_to_transit_gateway = ["0.0.0.0/0"]
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      netmask                                         = each.value.tgw_subnet_netmask
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }
}

# TRANSIT GATEWAY ROUTES
# Transit Gateway Route Tables
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "Spoke_Route_Table-${var.identifier}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "post_inspection_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "Post_Inspection_Route_Table-${var.identifier}"
  }
}

# Transit Gateway Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "spoke_tgw_association" {
  for_each = module.spoke_vpcs

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection_tgw_association" {
  transit_gateway_attachment_id  = module.inspection_vpc["inspection-vpc"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# Transit Gateway Route Table Propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_propagation_to_post_inspection" {
  for_each = module.spoke_vpcs

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# Static Route (0.0.0.0/0) in the Spoke TGW Route Table sending all the traffic to the Inspection VPC
resource "aws_ec2_transit_gateway_route" "default_route_spoke_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.inspection_vpc["inspection-vpc"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# EC2 Instances (in Spoke VPCs)
module "compute" {
  for_each = module.spoke_vpcs
  source   = "./modules/compute"

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = { for k, v in each.value.private_subnet_attributes_by_az : k => v.id }
  number_azs               = var.vpcs[each.key].number_azs
  instance_type            = var.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

# SSM VPC endpoints (in Spoke VPCs)
module "vpc_endpoints" {
  for_each = module.spoke_vpcs
  source   = "./modules/vpc_endpoints"

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = { for k, v in each.value.private_subnet_attributes_by_az : k => v.id }
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoint_service_names
}

# IAM Role for the EC2 instances (access to Systems Manager)
module "iam" {
  source = "./modules/iam"

  identifier = var.identifier
}

