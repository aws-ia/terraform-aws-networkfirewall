<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module - Intra-VPC Inspection

This example builds AWS Network Firewall in a single VPC to perform intra-VPC inspection between its subnets. The image below shows an example of the architecture, routing configuration, and traffic flow.

<p align="center">
  <img src="../../images/single\_vpc\_intra\_subnet.png" alt="Intra-VPC Inspection - Architecture diagram" width="100%">
</p>

You can check the firewall policy applied in the *policy.tf* file.

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
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_icmp_private1_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp_private2_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-2"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"intra-vpc-inspection"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Information about the VPC to create. | `any` | <pre>{<br>  "cidr_block": "10.129.0.0/16",<br>  "endpoint_subnet_cidrs": [<br>    "10.129.9.48/28",<br>    "10.129.9.64/28",<br>    "10.129.9.80/28"<br>  ],<br>  "firewall_subnet_cidrs": [<br>    "10.129.9.0/28",<br>    "10.129.9.16/28",<br>    "10.129.9.32/28"<br>  ],<br>  "number_azs": 2,<br>  "private_subnet_cidrs": {<br>    "private1": [<br>      "10.129.0.0/24",<br>      "10.129.1.0/24",<br>      "10.129.2.0/24"<br>    ],<br>    "private2": [<br>      "10.129.3.0/24",<br>      "10.129.4.0/24",<br>      "10.129.5.0/24"<br>    ],<br>    "private3": [<br>      "10.129.6.0/24",<br>      "10.129.7.0/24",<br>      "10.129.8.0/24"<br>    ]<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC ID. |
<!-- END_TF_DOCS -->