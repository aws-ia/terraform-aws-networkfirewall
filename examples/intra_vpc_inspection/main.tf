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


