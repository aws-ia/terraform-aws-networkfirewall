# --- root/locals.tf ---

locals {
  availability_zones        = keys(var.vpc_subnets)
  vpc_type                  = keys(var.routing_configuration)[0]
  networkfirewall_endpoints = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }
}

# santizes tags for both aws / awscc providers
# aws   tags = module.tags.tags_aws
# awscc tags = module.tags.tags
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = var.tags
}