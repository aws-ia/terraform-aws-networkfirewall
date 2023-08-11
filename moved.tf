# --- root/moved.tf ---

# Moved blocks for VPC routes in routing configuration centralizded_inspection_with_egress
# Maximum number of AZs in a Region is 6 (us-east-1)

moved {
  from = aws_route.tgw_to_firewall_endpoint[0]
  to   = aws_route.connectivity_to_firewall_endpoint[0]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint[1]
  to   = aws_route.connectivity_to_firewall_endpoint[1]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint[2]
  to   = aws_route.connectivity_to_firewall_endpoint[2]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint[3]
  to   = aws_route.connectivity_to_firewall_endpoint[3]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint[4]
  to   = aws_route.connectivity_to_firewall_endpoint[4]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint[5]
  to   = aws_route.connectivity_to_firewall_endpoint[5]
}

# Moved blocks for VPC routes in routing configuration centralizded_inspection_without_egress
# Maximum number of AZs in a Region is 6 (us-east-1)

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[0]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[0]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[1]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[1]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[2]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[2]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[3]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[3]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[4]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[4]
}

moved {
  from = aws_route.tgw_to_firewall_endpoint_without_egress[5]
  to   = aws_route.connectivity_to_firewall_endpoint_without_egress[5]
}