# --- examples/intra_vpc_inspection/modules/vpc_endpoints/variables.tf ---

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
  type        = string
  description = "Endpoints Security Group ID."
}

variable "endpoints_service_names" {
  type        = any
  description = "Information about the VPC endpoints to create."
}
