# --- examples/single_vpc_logging/outputs.tf ---

output "vpc" {
  description = "VPC ID."
  value       = module.vpc.vpc_attributes.id
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.network_firewall.aws_network_firewall.id
}
