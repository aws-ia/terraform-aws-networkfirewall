<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module - Single VPC

This example builds AWS Network Firewall in a single VPC to inspect any ingress/egress traffic - distributed inspection model. The firewall endpoints are placed in subnets between the Internet gateway (IGW) and the public subnets (where you can place the Elastic Load Balancers and NAT gateways). The image below shows an example of the architecture, routing configuration, and traffic flow.

![Single VPC - Architecture diagram](../../images/single\_vpc.png)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_kms"></a> [iam\_kms](#module\_iam\_kms) | ./modules/iam_kms | n/a |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"us-east-2"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"single-vpc"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Information about the VPC to create. | `any` | <pre>{<br>  "cidr_block": "10.129.0.0/16",<br>  "firewall_subnet_cidrs": [<br>    "10.129.0.0/24",<br>    "10.129.1.0/24",<br>    "10.129.2.0/24"<br>  ],<br>  "number_azs": 2,<br>  "private_subnet_cidrs": [<br>    "10.129.6.0/24",<br>    "10.129.7.0/24",<br>    "10.129.8.0/24"<br>  ],<br>  "protected_subnet_cidrs": [<br>    "10.129.3.0/24",<br>    "10.129.4.0/24",<br>    "10.129.5.0/24"<br>  ]<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC ID. |
<!-- END_TF_DOCS -->