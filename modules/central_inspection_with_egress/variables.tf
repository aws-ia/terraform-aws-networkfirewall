# --- modules/central_inspection_with_egress/variables.tf ---

variable "route_table_id" {
  description = "VPC public route table ID."
  type        = string
}

variable "routes" {
  description = "List of destination routes to forward via the TGW."
  type        = list(string)
}

variable "vpc_endpoint_id" {
  description = "Network Firewall endpoint ID."
  type        = string
}