<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module - Centralized Inspection VPC (with egress traffic) in a Hub and Spoke architecture with AWS Transit Gateway

This example shows the creation of a centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway, with the idea of managing the traffic inspection at scale (East/West and North/South). This example creates the following resources:

* Outside of the Network Firewall module:
  * Firewall policies - in `policy.tf`
  * AWS Transit Gateway.
  * Inspection VPC, attached to the Transit Gateway, and with NAT gateways (to allow egress traffic).
  * Routing in the Inspection VPC to route traffic from the NAT gateways to the Internet (0.0.0.0/0), and from the inspection subnets to the Transit Gateway (network's supernet defined in `variables.tf`).
* Created by the Network Firewall mdodule:
  * AWS Network Firewall resource.
  * Routing to the firewall endpoints (from the transit\_gateway and public subnets).

The AWS Region used in the example is **eu-west-1 (Ireland)**.

## Prerequisites

* An AWS account with an IAM user with the appropriate permissions
* Terraform installed

## Code Principles

* Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage

* Clone the repository
* Edit the *variables.tf* file in the project root directory

**Note** Network Firewall endpoints will be deployed in all the Availability Zones used in the example (*var.inspection\_vpc.number\_azs*). By default, the number of AZs used is 2 to follow best practices. Take that into account when doing tests from a cost perspective.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inspection_vpc"></a> [inspection\_vpc](#module\_inspection\_vpc) | aws-ia/vpc/aws | = 3.0.1 |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"central-inspection-egress"` | no |
| <a name="input_inspection_vpc"></a> [inspection\_vpc](#input\_inspection\_vpc) | VPCs to create | `any` | <pre>{<br>  "cidr_block": "10.129.0.0/16",<br>  "number_azs": 2,<br>  "private_subnet_netmask": 28,<br>  "public_subnet_netmask": 28,<br>  "tgw_subnet_netmask": 28<br>}</pre> | no |
| <a name="input_supernet"></a> [supernet](#input\_supernet) | Supernet CIDR block. | `string` | `"10.0.0.0/8"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inspection_vpc"></a> [inspection\_vpc](#output\_inspection\_vpc) | VPCs created. |
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | AWS Transit Gateway ID. |
<!-- END_TF_DOCS -->