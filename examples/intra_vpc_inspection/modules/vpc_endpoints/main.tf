# --- examples/intra_vpc_inspection/modules/vpc_endpoints/main.tf ---

# VPC ENDPOINTS
resource "aws_vpc_endpoint" "endpoint" {
  for_each = var.endpoints_service_names

  vpc_id              = var.vpc_id
  service_name        = each.value.name
  vpc_endpoint_type   = each.value.type
  subnet_ids          = values(var.vpc_subnets)
  security_group_ids  = [var.endpoints_security_group]
  private_dns_enabled = each.value.private_dns
}