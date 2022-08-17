# --- examples/intra_vpc_inspection/modules/vpc_endpoints/outputs.tf ---

output "endpoint_ids" {
  value       = { for k, v in aws_vpc_endpoint.endpoint : k => v.id }
  description = "VPC Endpoints information."
}