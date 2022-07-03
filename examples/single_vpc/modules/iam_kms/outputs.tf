# --- examples/single_vpc/modules/iam_kms/output.tf ---

output "kms_arn" {
  value       = aws_kms_key.log_key.arn
  description = "ARN of the KMS key created."
}