# --- examples/intra_vpc_inspection/modules/vpc/outputs.tf ---

output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs."
  value = {
    private1 = { for k, v in aws_subnet.private1 : k => v.id }
    private2 = { for k, v in aws_subnet.private2 : k => v.id }
    private3 = { for k, v in aws_subnet.private3 : k => v.id }
    firewall = { for k, v in aws_subnet.firewall : k => v.id }
    endpoint = { for k, v in aws_subnet.endpoint : k => v.id }
  }
}

output "subnet_cidrs" {
  description = "CIDR blocks of the different subnets."
  value = {
    private1 = local.private1_subnets
    private2 = local.private2_subnets
    private3 = local.private3_subnets
    firewall = local.firewall_subnets
    endpoint = local.endpoint_subnets
  }
}

output "route_table_ids" {
  description = "Route Table IDs."
  value = {
    private1 = { for k, v in aws_route_table.private1_rt : k => v.id }
    private2 = { for k, v in aws_route_table.private2_rt : k => v.id }
    private3 = { for k, v in aws_route_table.private3_rt : k => v.id }
    firewall = { for k, v in aws_route_table.firewall_rt : k => v.id }
    endpoint = { for k, v in aws_route_table.endpoint_rt : k => v.id }
  }
}