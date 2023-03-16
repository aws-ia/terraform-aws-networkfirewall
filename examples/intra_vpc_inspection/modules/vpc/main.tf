# --- examples/intra_vpc_inspection/modules/vpc/main.tf ---

# List of AZs available in the AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Subnet maps: key(az) => subnet_id
  private1_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.private1, 0, var.number_azs)[i]
  })
  private2_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.private2, 0, var.number_azs)[i]
  })
  private3_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.private3, 0, var.number_azs)[i]
  })
  firewall_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.firewall, 0, var.number_azs)[i]
  })
  endpoint_subnets = tomap({
    for i, az in slice(data.aws_availability_zones.available.names, 0, var.number_azs) :
    az => slice(var.subnet_cidr_blocks.endpoint, 0, var.number_azs)[i]
  })
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "vpc-${var.identifier}"
  }
}

# SUBNETS
# Private Subnets 1
resource "aws_subnet" "private1" {
  for_each = local.private1_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "private1-subnet-${each.key}"
  }
}

# Private Subnets 2
resource "aws_subnet" "private2" {
  for_each = local.private2_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "private2-subnet-${each.key}"
  }
}

# Private Subnets 3
resource "aws_subnet" "private3" {
  for_each = local.private3_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "private3-subnet-${each.key}"
  }
}

# Firewall Subnets
resource "aws_subnet" "firewall" {
  for_each = local.firewall_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "firewall-subnet-${each.key}"
  }
}

# Endpoint Subnets
resource "aws_subnet" "endpoint" {
  for_each = local.endpoint_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "endpoint-subnet-${each.key}"
  }
}

# ROUTE TABLES
# Private subnets 1
resource "aws_route_table" "private1_rt" {
  for_each = local.private1_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private1-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private1_rt_association" {
  for_each = local.private1_subnets

  route_table_id = aws_route_table.private1_rt[each.key].id
  subnet_id      = aws_subnet.private1[each.key].id
}

# Private subnets 2
resource "aws_route_table" "private2_rt" {
  for_each = local.private2_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private2-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private2_rt_association" {
  for_each = local.private2_subnets

  route_table_id = aws_route_table.private2_rt[each.key].id
  subnet_id      = aws_subnet.private2[each.key].id
}

# Private subnets 3
resource "aws_route_table" "private3_rt" {
  for_each = local.private1_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private3-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private3_rt_association" {
  for_each = local.private3_subnets

  route_table_id = aws_route_table.private3_rt[each.key].id
  subnet_id      = aws_subnet.private3[each.key].id
}

# Firewall subnets
resource "aws_route_table" "firewall_rt" {
  for_each = local.firewall_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "firewall-rt-${each.key}"
  }
}

resource "aws_route_table_association" "firewall_rt_association" {
  for_each = local.firewall_subnets

  route_table_id = aws_route_table.firewall_rt[each.key].id
  subnet_id      = aws_subnet.firewall[each.key].id
}

# Endpoint subnets
resource "aws_route_table" "endpoint_rt" {
  for_each = local.endpoint_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "endpoint-rt-${each.key}"
  }
}

resource "aws_route_table_association" "endpoint_rt_association" {
  for_each = local.endpoint_subnets

  route_table_id = aws_route_table.endpoint_rt[each.key].id
  subnet_id      = aws_subnet.endpoint[each.key].id
}
