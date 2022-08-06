# --- examples/single_vpc/modules/vpc/main.tf ---

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

# VPC
resource "awscc_ec2_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = [
    { "key" = "Name", "value" = "vpc-${var.identifier}" }
  ]
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = awscc_ec2_vpc.vpc.vpc_id

  tags = {
    Name = "igw-${var.identifier}"
  }
}

# SUBNETS
# Firewall Subnets
resource "aws_subnet" "firewall" {
  for_each = local.firewall_subnets

  vpc_id            = awscc_ec2_vpc.vpc.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "firewall-subnet-${each.key}"
  }
}

# Protected Subnet (public)
resource "aws_subnet" "protected" {
  for_each = local.protected_subnets

  vpc_id            = awscc_ec2_vpc.vpc.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "protected-subnet-${each.key}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = awscc_ec2_vpc.vpc.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "private-subnet-${each.key}"
  }
}

# ROUTE TABLES
# Internet gateway
resource "awscc_ec2_route_table" "igw_rt" {
  vpc_id = awscc_ec2_vpc.vpc.vpc_id

  tags = [
    { "key" = "Name", "value" = "igw-rt" }
  ]
}

resource "awscc_ec2_gateway_route_table_association" "igw_rt_association" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = awscc_ec2_route_table.igw_rt.id
}

# Firewall subnets
resource "awscc_ec2_route_table" "firewall_rt" {
  for_each = local.firewall_subnets

  vpc_id = awscc_ec2_vpc.vpc.vpc_id

  tags = [
    { "key" = "Name", "value" = "firewall-rt-${each.key}" }
  ]
}

resource "awscc_ec2_subnet_route_table_association" "firewall_rt_association" {
  for_each = local.firewall_subnets

  route_table_id = awscc_ec2_route_table.firewall_rt[each.key].id
  subnet_id      = aws_subnet.firewall[each.key].id
}

# Protected subnets
resource "awscc_ec2_route_table" "protected_rt" {
  for_each = local.protected_subnets

  vpc_id = awscc_ec2_vpc.vpc.vpc_id

  tags = [
    { "key" = "Name", "value" = "protected-rt-${each.key}" }
  ]
}

resource "awscc_ec2_subnet_route_table_association" "protected_rt_association" {
  for_each = local.protected_subnets

  route_table_id = awscc_ec2_route_table.protected_rt[each.key].id
  subnet_id      = aws_subnet.protected[each.key].id
}

# Private subnets
resource "awscc_ec2_route_table" "private_rt" {
  for_each = local.private_subnets

  vpc_id = awscc_ec2_vpc.vpc.vpc_id

  tags = [
    { "key" = "Name", "value" = "private-rt-${each.key}" }
  ]
}

resource "awscc_ec2_subnet_route_table_association" "private_rt_association" {
  for_each = local.private_subnets

  route_table_id = awscc_ec2_route_table.private_rt[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}

# NAT GATEWAY AND EIP (in Protected subnets)
resource "aws_eip" "eip_natgw" {
  for_each = local.protected_subnets
  vpc      = true
}

resource "awscc_ec2_nat_gateway" "natgw" {
  for_each = local.protected_subnets

  subnet_id         = aws_subnet.protected[each.key].id
  allocation_id     = aws_eip.eip_natgw[each.key].id
  connectivity_type = "public"

  tags = [
    { "key" = "Name", "value" = "natgw-${each.key}" }
  ]
}

# ROUTES
# Firewall subnet Route Tables - 0.0.0.0/0 to IGW
resource "aws_route" "firewall_to_igw" {
  for_each = local.firewall_subnets

  route_table_id         = awscc_ec2_route_table.firewall_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Private subnet Route Tables - 0.0.0.0/0 to NATGW
resource "aws_route" "private_to_natgw" {
  for_each = local.private_subnets

  route_table_id         = awscc_ec2_route_table.private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = awscc_ec2_nat_gateway.natgw[each.key].id
}
