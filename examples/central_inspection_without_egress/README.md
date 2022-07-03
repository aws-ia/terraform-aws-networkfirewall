<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module - Centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway

This example shows the creation of a centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway, with the idea of managing the traffic inspection at scale (East/West). The Inspection VPC is created only with AWS Transit Gateway ENIs and the firewall endpoints. The image below shows an example of the architecture, routing configuration, and traffic flow.

![Central Inspection VPC - Architecture diagram](../../images/centralized\_vpc.png)

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"us-east-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"central-inspection"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create | `any` | <pre>{<br>  "inspection-vpc": {<br>    "cidr_block": "10.129.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 28,<br>    "tgw_subnet_netmask": 28,<br>    "type": "inspection"<br>  },<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.0.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 28,<br>    "tgw_subnet_netmask": 28,<br>    "type": "spoke"<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.1.0.0/16",<br>    "number_azs": 2,<br>    "private_subnet_netmask": 24,<br>    "tgw_subnet_netmask": 28,<br>    "type": "spoke"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inspection_vpc"></a> [inspection\_vpc](#output\_inspection\_vpc) | Inspection VPC ID. |
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_spoke_vpcs"></a> [spoke\_vpcs](#output\_spoke\_vpcs) | Spoke VPC IDs. |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | AWS Transit Gateway ID. |
<!-- END_TF_DOCS -->