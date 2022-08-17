# --- modules/central_inspection_with_egress_routing/variables.tf ---

variable "route_table_id" {
  type        = string
  description = "Route Table IDs."
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of destination CIDR blocks."
}

variable "vpc_endpoint_id" {
  type        = string
  description = "VPC endpoint IDs."
}


