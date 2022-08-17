# --- modules/central_inspection_with_egress_routing/main.tf ---

resource "aws_route" "route_public_to_firewall_endpoint" {
  count = length(var.cidr_blocks)

  route_table_id         = var.route_table_id
  destination_cidr_block = var.cidr_blocks[count.index]
  vpc_endpoint_id        = var.vpc_endpoint_id
}