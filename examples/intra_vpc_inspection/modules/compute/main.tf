# --- examples/intra_vpc_inspection/modules/compute/main.tf ---

# Data resource to determine the latest Amazon Linux2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# Local values
locals {
  # Number of Availability Zones used by the user (taken from the number of subnets defined)
  availability_zones = keys(var.vpc_subnets)
}

# EC2 instances
resource "aws_instance" "ec2_instance" {
  count = var.number_azs

  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = false
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.ec2_security_group]
  subnet_id                   = var.vpc_subnets[local.availability_zones[count.index]]
  iam_instance_profile        = var.ec2_iam_instance_profile

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.subnet_type}-instance-${count.index + 1}-${var.identifier}"
  }
}