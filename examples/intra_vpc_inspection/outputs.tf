# --- examples/intra_vpc_inspection/outputs.tf ---

output "vpc" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.network_firewall.aws_network_firewall.id
}

output "ec2_instances" {
  description = "EC2 Instances."
  value       = { for k, v in module.compute : k => { for az, ec2 in v.ec2_instances : az => ec2.id } }
}

output "vpc_endpoints" {
  description = "SSM VPC endpoints."
  value       = module.vpc_endpoints.endpoint_ids
}
