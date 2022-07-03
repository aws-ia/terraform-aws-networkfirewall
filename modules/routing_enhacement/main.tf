# --- modules/routing_enhacement/main.tf ---

resource "aws_route" "igw_route_table_to_protected_subnets" {
  count = var.number_azs

  route_table_id         = var.route_tables[var.availability_zones[count.index]]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = var.firewall_endpoints[var.availability_zones[count.index]]
}