# --- root/outputs.tf ---

output "aws_network_firewall" {
  description = "Full output of aws_networkfirewall_firewall resource."
  value       = aws_networkfirewall_firewall.anfw
}