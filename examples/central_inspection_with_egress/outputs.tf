# --- examples/central_inspection_with_egress/outputs.tf ---

output "transit_gateway" {
  description = "AWS Transit Gateway ID."
  value       = aws_ec2_transit_gateway.tgw.id
}

output "vpcs" {
  description = "VPCs created."
  value = {
    inspection = module.inspection_vpc["inspection-vpc"].vpc_attributes.id
    spokes     = { for k, v in module.spoke_vpcs : k => v.vpc_attributes.id }
  }
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.network_firewall.aws_network_firewall.id
}

output "ec2_instances" {
  description = "EC2 Instances ID."
  value       = { for k, v in module.compute : k => { for az, ec2 in v.ec2_instances : az => ec2.id } }
}

output "vpc_endpoints" {
  description = "VPC Endpoints ID."
  value       = { for k, v in module.vpc_endpoints : k => v.endpoint_ids }
}