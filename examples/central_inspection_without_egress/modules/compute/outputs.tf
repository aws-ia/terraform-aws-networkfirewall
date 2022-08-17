# --- examples/central_inspection_without_egress/modules/compute/outputs.tf ---

output "ec2_instances" {
  value       = zipmap(local.availability_zones, aws_instance.ec2_instance)
  description = "List of instances created."
}