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

# CloudWath Log Groups - for Flow and Alert
resource "aws_cloudwatch_log_group" "alert_lg" {
  name              = "alert-anfw-${var.identifier}"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.log_key.arn
}

resource "aws_cloudwatch_log_group" "flow_lg" {
  name              = "flow-anfw-${var.identifier}"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.log_key.arn
}

# AWS Network Firewall
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "0.1.1"

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

  logging_configuration = {
    flow_log = {
      cloudwatch_logs = {
        logGroupName = aws_cloudwatch_log_group.flow_lg.name
      }
    }
    alert_log = {
      cloudwatch_logs = {
        logGroupName = aws_cloudwatch_log_group.alert_lg.name
      }
    }
  }
}

# DATA SOURCE: AWS CALLER IDENTITY - Used to get the Account ID
data "aws_caller_identity" "current" {}

# KMS
# KMS Key
resource "aws_kms_key" "log_key" {
  description             = "KMS Logs Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.policy_kms_logs_document.json

  tags = {
    Name = "kms-key-${var.identifier}"
  }
}

# KMS Policy - it allows the use of the Key by the CloudWatch log groups created in this sample
data "aws_iam_policy_document" "policy_kms_logs_document" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Enable KMS to be used by CloudWatch Logs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

