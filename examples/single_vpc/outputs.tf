# --- examples/single_vpc/outputs.tf ---

output "vpc" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.network_firewall.aws_network_firewall.id
}
