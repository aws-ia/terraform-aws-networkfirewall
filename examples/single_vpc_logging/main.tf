# --- examples/single_vpc_logging/main.tf ---

# AWS Network Firewall
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "1.0.0"

  network_firewall_name   = "anfw-${var.identifier}"
  network_firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.vpc.vpc_attributes.id
  number_azs  = var.vpc.number_azs
  vpc_subnets = { for k, v in module.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "inspection" }

  routing_configuration = {
    single_vpc = {
      igw_route_table               = aws_route_table.igw_route_table.id
      protected_subnet_route_tables = { for k, v in module.vpc.rt_attributes_by_type_by_az.public : k => v.id }
      protected_subnet_cidr_blocks = tomap({
        for i, az in module.vpc.azs : az => var.vpc.protected_subnet_cidrs[i]
      })
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

# VPC Module - https://github.com/aws-ia/terraform-aws-vpc
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 4.3.0"

  name       = "single_vpc"
  cidr_block = var.vpc.cidr_block
  az_count   = var.vpc.number_azs

  subnets = {
    public = {
      cidrs          = var.vpc.protected_subnet_cidrs
      connect_to_igw = false
    }
    private    = { cidrs = var.vpc.private_subnet_cidrs }
    inspection = { cidrs = var.vpc.inspection_subnet_cidrs }
  }
}

# Internet gateway route table
resource "aws_route_table" "igw_route_table" {
  vpc_id = module.vpc.vpc_attributes.id

  tags = {
    Name = "igw-route-table"
  }
}

resource "aws_route_table_association" "igw_route_table_assoc" {
  gateway_id     = module.vpc.internet_gateway.id
  route_table_id = aws_route_table.igw_route_table.id
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

