# --- examples/single_vpc/modules/vpc/locals.tf ---

# List of AZs available in the AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Subnet maps: key(az) => subnet_id
  firewall_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.firewall, 0, var.number_azs)[i]
  })
  protected_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.protected, 0, var.number_azs)[i]
  })
  private_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.private, 0, var.number_azs)[i]
  })
}