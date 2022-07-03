# --- examples/single_vpc/modules/vpc/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block."
}

variable "number_azs" {
  type        = string
  description = "Number of Availability Zones to use."
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for each of the subnets inside the VPC."
  type = object({
    firewall  = list(string)
    protected = list(string)
    private   = list(string)
  })
}

