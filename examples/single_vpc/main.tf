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
      igw_route_table               = module.vpc.route_table_ids.igw
      protected_subnet_route_tables = module.vpc.route_table_ids.protected
      protected_subnet_cidr_blocks  = module.vpc.subnet_cidrs.protected
    }
  }
}

# EC2 Instances
module "compute" {
  source = "./modules/compute"

  identifier               = var.identifier
  vpc_id                   = module.vpc.vpc_id
  vpc_subnets              = module.vpc.subnet_ids.private
  number_azs               = var.vpc.number_azs
  instance_type            = var.vpc.instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

# VPC Endpoints (for SSM access)
module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  identifier               = var.identifier
  vpc_id                   = module.vpc.vpc_id
  vpc_subnets              = module.vpc.subnet_ids.private
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoint_service_names
}

# IAM Role for the EC2 instances (access to Systems Manager)
module "iam" {
  source = "./modules/iam"

  identifier = var.identifier
}


