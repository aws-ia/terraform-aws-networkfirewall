# --- examples/single_vpc/modules/vpc/outputs.tf ---

output "vpc_id" {
  description = "VPC ID."
  value       = awscc_ec2_vpc.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs."
  value = {
    firewall  = { for k, v in aws_subnet.firewall : k => v.id }
    protected = { for k, v in aws_subnet.protected : k => v.id }
    private   = { for k, v in aws_subnet.private : k => v.id }
  }
}

output "subnet_cidrs" {
  description = "CIDR blocks of the different subnets."
  value = {
    firewall  = local.firewall_subnets
    protected = local.protected_subnets
    private   = local.private_subnets
  }
}

output "route_table_ids" {
  description = "Route Table IDs."
  value = {
    igw       = awscc_ec2_route_table.igw_rt.id
    firewall  = { for k, v in awscc_ec2_route_table.firewall_rt : k => v.id }
    protected = { for k, v in awscc_ec2_route_table.protected_rt : k => v.id }
    private   = { for k, v in awscc_ec2_route_table.private_rt : k => v.id }
  }
}

output "nat_gateways" {
  description = "NAT gateways."
  value       = { for k, v in awscc_ec2_nat_gateway.natgw : k => v.id }
}