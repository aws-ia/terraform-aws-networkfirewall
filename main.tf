# --- root/variables.tf ---

# santizes tags for both aws / awscc providers
# aws   tags = module.tags.tags_aws
# awscc tags = module.tags.tags
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.6"

  tags = var.tags
}

# Local values
locals {
  # Number of Availability Zones used by the user (taken from the number of subnets defined)
  availability_zones = keys(var.vpc_subnets)
  # Obtaining the key of the routing configuration chosen: "single_vpc", "single_vpc_intra_subnet", "centralized_inspection_without_egress", or "centralized_inspection_with_egress"
  vpc_type = keys(var.routing_configuration)[0]
  # Map: key (availability zone ID) => value (firewall endpoint ID)
  networkfirewall_endpoints = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }
}

# AWS NETWORK FIREWALL RESOURCE
resource "aws_networkfirewall_firewall" "anfw" {
  name                = var.network_firewall_name
  description         = var.network_firewall_description
  firewall_policy_arn = var.network_firewall_policy

  delete_protection                 = var.network_firewall_delete_protection
  firewall_policy_change_protection = var.network_firewall_policy_change_protection
  subnet_change_protection          = var.network_firewall_subnet_change_protection

  vpc_id = var.vpc_id
  dynamic "subnet_mapping" {
    for_each = values(var.vpc_subnets)

    content {
      subnet_id       = subnet_mapping.value
      ip_address_type = "IPV4"
    }
  }

  dynamic "encryption_configuration" {
    for_each = var.network_firewall_encryption_key_arn == null ? [] : [1]

    content {
      type   = "CUSTOMER_KMS"
      key_id = var.network_firewall_encryption_key_arn
    }
  }

  tags = module.tags.tags_aws
}

# ROUTES: SINGLE VPC
# Route from the Internet gateway route table to the specified CIDR blocks via the firewall endpoints
resource "aws_route" "igw_route_table_to_protected_subnets" {
  count = local.vpc_type == "single_vpc" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.single_vpc.igw_route_table
  destination_cidr_block = var.routing_configuration.single_vpc.protected_subnet_cidr_blocks[local.availability_zones[count.index]]
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# Route from the "protected" subnets to 0.0.0.0/0 via the firewall endpoints
resource "aws_route" "protected_route_table_to_internet" {
  count = local.vpc_type == "single_vpc" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.single_vpc.protected_subnet_route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# ROUTES: SINGLE VPC INTRA ROUTING
module "intra_vpc_routing" {
  count  = local.vpc_type == "intra_vpc_inspection" ? var.routing_configuration.intra_vpc_inspection.number_routes : 0
  source = "./modules/intra_vpc_routing"

  number_azs         = var.number_azs
  availability_zones = local.availability_zones
  route_tables       = var.routing_configuration.intra_vpc_inspection.routes[count.index].source_subnet_route_tables
  cidr_blocks        = var.routing_configuration.intra_vpc_inspection.routes[count.index].destination_subnet_cidr_blocks
  firewall_endpoints = local.networkfirewall_endpoints
}

# ROUTES: Central Inspection VPC (without egress) 
# Route from the connectivity subnets (Transit Gateway or Cloud WAN's core network) to 0.0.0.0/0 via the firewall endpoints
resource "aws_route" "connectivity_to_firewall_endpoint_without_egress" {
  count = local.vpc_type == "centralized_inspection_without_egress" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.centralized_inspection_without_egress.connectivity_subnet_route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# ROUTES: Central Inspection VPC (with egress) 
# Route from the connectivity subnets (Transit Gateway or Cloud WAN's core network) to 0.0.0.0/0 via the firewall endpoints
resource "aws_route" "connectivity_to_firewall_endpoint" {
  count = local.vpc_type == "centralized_inspection_with_egress" ? var.number_azs : 0

  route_table_id         = var.routing_configuration.centralized_inspection_with_egress.connectivity_subnet_route_tables[local.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# Route from the public subnets to the AWS network via the firewall endpoints
# Several routes can be configured in each AZ, so we need to call the vpc_route module for each AZ in place. The module creates an aws_route resource per each CIDR block configured.
module "central_inspection_with_egress_routing" {
  count  = local.vpc_type == "centralized_inspection_with_egress" ? var.number_azs : 0
  source = "./modules/central_inspection_with_egress_routing"

  route_table_id  = var.routing_configuration.centralized_inspection_with_egress.public_subnet_route_tables[local.availability_zones[count.index]]
  cidr_blocks     = var.routing_configuration.centralized_inspection_with_egress.network_cidr_blocks
  vpc_endpoint_id = local.networkfirewall_endpoints[local.availability_zones[count.index]]
}

# LOGGING: Module will be used when a logging_configuration is defined
module "logging" {
  count  = length(var.logging_configuration) != 0 ? 1 : 0
  source = "./modules/logging"

  firewall_arn          = aws_networkfirewall_firewall.anfw.arn
  logging_configuration = var.logging_configuration
}
