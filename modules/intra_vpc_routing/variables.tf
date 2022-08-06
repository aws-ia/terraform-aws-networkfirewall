# --- modules/intra_vpc_routing/variables.tf ---

variable "number_azs" {
  type        = number
  description = "Number of Availability Zones."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones."
}

variable "route_tables" {
  type        = map(string)
  description = "Map of Route Tables to configure (key = az, value = route table ID)."
}

variable "cidr_blocks" {
  type        = map(string)
  description = "Map of destination's CIDR blocks (key = az, value = CIDR block)."
}

variable "firewall_endpoints" {
  type        = map(string)
  description = "Map of firewall endpoints (key = az, value = endpoint ID)."
}


