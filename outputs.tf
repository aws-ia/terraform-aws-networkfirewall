# --- root/outputs.tf ---

output "aws_network_firewall" {
  description = "AWS Network Firewall."
  value       = aws_networkfirewall_firewall.anfw
}