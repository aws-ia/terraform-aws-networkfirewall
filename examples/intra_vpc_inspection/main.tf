# --- examples/intra_vpc_inspection/main.tf ---

# VPC (from local module)
module "vpc" {
  source = "./modules/vpc"

  identifier = var.identifier
  cidr_block = var.vpc.cidr_block
  number_azs = var.vpc.number_azs
  subnet_cidr_blocks = {
    private1 = var.vpc.private_subnet_cidrs.private1
    private2 = var.vpc.private_subnet_cidrs.private2
    private3 = var.vpc.private_subnet_cidrs.private3
    firewall = var.vpc.firewall_subnet_cidrs
    endpoint = var.vpc.endpoint_subnet_cidrs
  }
}

# AWS Network Firewall
module "network_firewall" {
  source = "../.."

  network_firewall_name   = "anfw-${var.identifier}"
  network_firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.vpc.vpc_id
  number_azs  = var.vpc.number_azs
  vpc_subnets = module.vpc.subnet_ids.firewall

  routing_configuration = {
    intra_vpc_inspection = {
      number_routes = 6
      routes = [
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private1
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private2
        },
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private2
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private1
        },
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private1
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private3
        },
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private3
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private1
        },
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private2
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private3
        },
        {
          source_subnet_route_tables     = module.vpc.route_table_ids.private3
          destination_subnet_cidr_blocks = module.vpc.subnet_cidrs.private2
        }
      ]
    }
  }
}

# Security Groups
#tfsec:ignore:custom-custom-cus005 tfsec:ignore:custom-custom-cus004
resource "aws_security_group" "security_group" {
  for_each = local.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-security-group-${var.identifier}"
  }
}

# EC2 Instances
module "compute" {
  for_each = var.vpc.private_subnet_cidrs
  source   = "./modules/compute"

  identifier               = var.identifier
  subnet_type              = each.key
  vpc_id                   = module.vpc.vpc_id
  vpc_subnets              = module.vpc.subnet_ids[each.key]
  number_azs               = var.vpc.number_azs
  instance_type            = var.vpc.instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = aws_security_group.security_group["instance"].id
}

# VPC Endpoints (for SSM access)
module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  identifier               = var.identifier
  vpc_id                   = module.vpc.vpc_id
  vpc_subnets              = module.vpc.subnet_ids.endpoint
  endpoints_security_group = aws_security_group.security_group["endpoints"].id
  endpoints_service_names  = local.endpoint_service_names
}

# IAM Role for the EC2 instances (access to Systems Manager)
module "iam" {
  source = "./modules/iam"

  identifier = var.identifier
}


