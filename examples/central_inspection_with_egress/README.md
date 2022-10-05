<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module - Centralized Inspection VPC (with egress traffic) in a Hub and Spoke architecture with AWS Transit Gateway

This example shows the creation of a centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway, with the idea of managing the traffic inspection at scale (East/West and North/South). The Inspection VPC is created with AWS Transit Gateway ENIs, firewall endpoints, and NAT gateways (allowing a centralized egress point). The image below shows an example of the architecture, routing configuration, and traffic flow.

<p align="center">
  <img src="../../images/centralized\_vpc\_with\_egress.png" alt="Central Inspection VPC with Egress traffic - Architecture diagram" width="100%">
</p>

The AWS Region used in the example is **eu-west-1 (Ireland)**, creating 2 Spoke VPCs and 1 Inspection VPC (with egress). To test that the traffic is sent via the AWS Network Firewall, the firewall policy (in the *firewall.tf* policy file) allows ICMP traffic between the Spoke VPCs (but not to the Internet) and HTTPS traffic to any *.amazon.com domain.

## Prerequisites

* An AWS account with an IAM user with the appropriate permissions
* Terraform installed

## Code Principles

* Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage

* Clone the repository
* Edit the *variables.tf* file in the project root directory

**Note** Network Firewall endpoints will be deployted in all the Availability Zones used in the example (*var.vpc.number\_azs*). By default, the number of AZs used is 2 to follow best practices. Take that into account when doing tests from a cost perspective.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.73.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inspection_vpc"></a> [inspection\_vpc](#module\_inspection\_vpc) | aws-ia/vpc/aws | = 1.4.1 |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | ../.. | n/a |
| <a name="module_spoke_vpcs"></a> [spoke\_vpcs](#module\_spoke\_vpcs) | aws-ia/vpc/aws | = 1.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.default_route_spoke_to_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.spoke_vpc_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.inspection_tgw_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.spoke_tgw_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.spoke_propagation_to_post_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"central-inspection-egress"` | no |
| <a name="input_supernet"></a> [supernet](#input\_supernet) | Supernet CIDR block. | `string` | `"10.0.0.0/8"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create | `any` | <pre>{<br>  "inspection-vpc": {<br>    "cidr_block": "10.129.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 28,<br>    "public_subnet_netmask": 28,<br>    "tgw_subnet_netmask": 28,<br>    "type": "inspection"<br>  },<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.0.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 28,<br>    "tgw_subnet_netmask": 28,<br>    "type": "spoke"<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.1.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 24,<br>    "tgw_subnet_netmask": 28,<br>    "type": "spoke"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | AWS Transit Gateway ID. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPCs created. |
<!-- END_TF_DOCS -->