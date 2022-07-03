# --- examples/single_vpc/main.tf ---

# VPC (from local module)
module "vpc" {
  source = "./modules/vpc"

  identifier = var.identifier
  cidr_block = var.vpc.cidr_block
  number_azs = var.vpc.number_azs
  subnet_cidr_blocks = {
    firewall  = var.vpc.firewall_subnet_cidrs
    protected = var.vpc.protected_subnet_cidrs
    private   = var.vpc.private_subnet_cidrs
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
    single_vpc = {
      igw_route_table = module.vpc.route_table_ids.igw
      route_tables    = module.vpc.route_table_ids.protected
      cidr_blocks     = module.vpc.subnet_cidrs.protected
    }
  }
}

# IAM Roles and KMS Key
module "iam_kms" {
  source = "./modules/iam_kms"

  identifier = var.identifier
  aws_region = var.aws_region
}


