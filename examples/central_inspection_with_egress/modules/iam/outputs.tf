# --- examples/central_inspection_without_egress/modules/iam/output.tf ---

output "ec2_iam_instance_profile" {
  value       = aws_iam_instance_profile.ec2_instance_profile.id
  description = "EC2 instance profile to use in the EC2 instace(s) to create."
}