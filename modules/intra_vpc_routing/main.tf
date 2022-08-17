# --- modules/intra_vpc_routing/main.tf ---

resource "aws_route" "igw_route_table_to_protected_subnets" {
  count = var.number_azs

  route_table_id         = var.route_tables[var.availability_zones[count.index]]
  destination_cidr_block = var.cidr_blocks[var.availability_zones[count.index]]
  vpc_endpoint_id        = var.firewall_endpoints[var.availability_zones[count.index]]
}