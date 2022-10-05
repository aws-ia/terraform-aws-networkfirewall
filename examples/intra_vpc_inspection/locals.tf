# --- examples/intra_vpc_inspection/locals.tf ---

locals {
  security_groups = {
    instance = {
      name        = "instance_security_group"
      description = "Instance SG (Allowing ICMP and HTTPS access)"
      ingress = {
        icmp = {
          description = "Allowing ICMP traffic"
          from        = -1
          to          = -1
          protocol    = "icmp"
          cidr_blocks = [var.vpc.cidr_block] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
        }
        https = {
          description = "Allowing HTTPS traffic"
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = [var.vpc.cidr_block] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
        }
      }
      egress = {
        any = {
          description = "Any traffic"
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.vpc.cidr_block] #tfsec:ignore:aws-vpc-no-public-egress-sgr
        }
      }
    }
    endpoints = {
      name        = "endpoints_sg"
      description = "Security Group for SSM connection"
      ingress = {
        https = {
          description = "Allowing HTTPS"
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = [var.vpc.cidr_block] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
        }
      }
      egress = {
        any = {
          description = "Any traffic"
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.vpc.cidr_block] #tfsec:ignore:aws-vpc-no-public-egress-sgr
        }
      }
    }
  }

  endpoint_service_names = {
    ssm = {
      name        = "com.amazonaws.${var.aws_region}.ssm"
      type        = "Interface"
      private_dns = true
    }
    ssmmessages = {
      name        = "com.amazonaws.${var.aws_region}.ssmmessages"
      type        = "Interface"
      private_dns = true
    }
    ec2messages = {
      name        = "com.amazonaws.${var.aws_region}.ec2messages"
      type        = "Interface"
      private_dns = true
    }
  }
}