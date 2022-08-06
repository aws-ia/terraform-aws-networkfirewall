# --- examples/single_vpc/modules/vpc_endpoints/variables.tf ---

variable "identifier" {
  description = "Project identifier."
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the endpoint(s)."
}

variable "vpc_subnets" {
  type        = map(string)
  description = "List of the subnets to place the endpoint(s)."
}

variable "endpoints_security_group" {
  type        = any
  description = "Information about the Security Groups to create - for the VPC endpoints."
}

variable "endpoints_service_names" {
  type        = any
  description = "Information about the VPC endpoints to create."
}
