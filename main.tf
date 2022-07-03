# --- root/variables.tf ---

# AWS NETWORK FIREWALL RESOURCE
resource "aws_networkfirewall_firewall" "anfw" {
  name                              = var.network_firewall_name
  firewall_policy_arn               = var.network_firewall_policy
  firewall_policy_change_protection = var.network_firewall_policy_change_protection
  subnet_change_protection          = var.network_firewall_subnet_change_protection

  vpc_id = var.vpc_id
  dynamic "subnet_mapping" {
    for_each = values(var.vpc_subnets)

    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = module.tags.tags_aws
}

# ROUTES: VPC Ingress/Egress 
# Route from the Internet gateway route table to the specified CIDR blocks via the firewall endpoints
resource "aws_route" "igw_route_table_to_protected_subnets" {
  count = local.vpc_type == "single_vpc" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.single_vpc.igw_route_table
  destination_cidr_block = var.routing_configuration.single_vpc.cidr_blocks[local.availability_zones[count.index]]
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# Route from the "protected" subnets to 0.0.0.0/0 via the firewall endpoints
resource "aws_route" "protected_route_table_to_internet" {
  count = local.vpc_type == "single_vpc" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.single_vpc.route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# ROUTES: VPC Routing Enhacement
module "routing_enhacement" {
  for_each = try(var.routing_configuration.single_vpc_routing_enhacement, {})
  source   = "./modules/routing_enhacement"

  number_azs         = var.number_azs
  availability_zones = local.availability_zones
  route_tables       = each.value.route_tables
  cidr_blocks        = each.value.cidr_blocks
  firewall_endpoints = local.networkfirewall_endpoints
}

# ROUTES: Central Inspection VPC (without egress) 
resource "aws_route" "tgw_to_firewall_endpoint_without_egress" {
  count = local.vpc_type == "centralized_inspection_without_egress" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.centralized_inspection_without_egress.tgw_route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# ROUTES: Central Inspection VPC (with egress) 
# Route from the TGW subnets to 0.0.0.0/0 via the firewall endpoints
resource "aws_route" "tgw_to_firewall_endpoint" {
  count = local.vpc_type == "centralized_inspection_with_egress" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.centralized_inspection_with_egress.tgw_route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# Route from the public subnets to the TGW ENI (network cidr blocks) via the firewall endpoints
module "central_inspection_with_egress" {
  count  = local.vpc_type == "centralized_inspection_with_egress" ? var.number_azs : 0
  source = "./modules/central_inspection_with_egress"

  route_table_id  = var.routing_configuration.centralized_inspection_with_egress.public_route_tables[local.availability_zones[count.index]]
  routes          = var.routing_configuration.centralized_inspection_with_egress.network_cidr_blocks
  vpc_endpoint_id = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}