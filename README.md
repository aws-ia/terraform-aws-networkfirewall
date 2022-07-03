<!-- BEGIN_TF_DOCS -->
# AWS Network Firewall Module

AWS Network Firewall is a stateful, managed, network firewall and intrusion detection and prevention service for Amazon Virtual Private Clouds (Amazon VPCs). This module can be used to deploy an AWS Network Firewall resource in the desired VPC, automating all the routing and logging configuration when the resource is deployed.

This module only handles the creation of the infrastructure, leaving full freedom to the user to define the firewall rules (which should be done outside the module). Same applies to IAM roles and KMS keys when you define the logging of the firewall - rememeber that it is a best practice to encryt at rest your firewall logs.

## Usage

To create AWS Network Firewall in your VPC, you need to provide the following information:

- `network_firewall_name`= (Required|string) Name to provide the AWS Network Firewall resource.
- `network_firewall_policy`= (Required|string) ARN of the firewall policy to apply in the AWS Network Firewall resource. Check the definition of [AWS Network Firewall Policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) and [AWS Network Firewall Rule Groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) to see how you can create firewall policies.
- `network_firewall_policy_change_protection` = (Optional|bool) To indicate whether it is possible to change the associated firewall policy after creation. Defaults to `false`.
- `network_firewall_subnet_change_protection` = (Optional|bool) To indicate whether it is possible to change the associated subnet(s) after creation. Defaults to `false`.
- `vpc_id` = (Required|string) ID of the VPC where the AWS Network Firewall resource should be placed.
- `vpc_subnets` = (Required|map(string)) Map of subnet IDs to place the Network Firewall endpoints. Example:

```hcl
vpc_subnets = {
    us-east-1a = subnet-IDa
    us-east-1b = subnet-IDb
    us-east-1c = subnet-IDc
}
```
- `routing_configuration` = (Required|any) Configuration of the routing desired in the VPC. Depending the type of VPC, the information to provide is different. The type of VPCs supported are: `single_vpc`, `single_vpc_routing_enhacement`, `centralized_inspection_without_egress`, and `centralized_inspection_with_egress`. **Only one key (option) can be defined**. More information about the differences between each of the VPC types (and examples) can be checked in the section below.
- `tags`= (Optional|map(string)) List of tags to apply to the AWS Network Firewall resource.

## Routing configuration

Once the AWS Network Firewall resource is created, the routing to the firewall endpoints need to be created. However, depending the VPC and how we want to inspect the traffic, this routing configuration is going to be different. The module supports the routing configuration of 4 different types of VPCs, covering the most common [Inspection Deployment models with with AWS Network Firewall](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/inspection-deployment-models-with-AWS-network-firewall-ra.pdf).

### Single VPC

The first use case is when the firewall endpoints are located in the VPC to inspect the traffic from/to workloads in that same VPC - distributed inspection model. If using this routing configuration (`simple_vpc`) it is expected to place the firewall endpoints in subnets between the Internet gateway (IGW) and the public subnets (where you can place the Elastic Load Balancers and NAT gateways). The image below shows an example of the architecture, routing configuration, and traffic flow.

![Single VPC - Architecture diagram](./images/single\_vpc.png)

An example of the definition of this routing configuration is the following one:

```hcl
routing_configuration = {
    single_vpc = {
      igw_route_table = rtb-ID
      route_tables = {
        us-east-1a = rtb-IDa
        us-east-1b = rtb-IDb
        us-east-1c = rtb-IDc
      }
      cidr_blocks = {
        us-east-1a = "10.0.0.0/24"
        us-east-1b = "10.0.1.0/24"
        us-east-1c = "10.0.2.0/24"
      }
    }
}
```

### Single VPC (routing enhacement)

When placing firewall endpoints to inspect traffic between workloads inside the same VPC (between your EC2 instances and the database layer, for example) you can take advantage of the VPC routing enhacement - which allows you to include more specific routing than the local one (`single_vpc_routing_enhacement`). The image below shows an example of the architecture, routing configuration, and traffic flow.

![Single VPC with routing enhacement - Architecture diagram](./images/single\_vpc\_routing\_enhacement.png)

An example of the definition of this routing configuration is the following one. The module expects in this variable a map of routing configurations with two keys each of them - `route_tables` and `cidr_blocks`.

```hcl
routing_configuration = {
    single_vpc_routing_enhacement = {
      workload_to_db = {
        route_tables = {
          us-east-1a = rtb-IDa
          us-east-1b = rtb-IDb
          us-east-1c = rtb-IDc
        }
        cidr_blocks = {
          us-east-1a = "10.0.0.0/24"
          us-east-1b = "10.0.1.0/24"
          us-east-1c = "10.0.2.0/24"
        }
      }
      db_to_workload = {
        route_tables = {
          us-east-1a = rtb-IDaa
          us-east-1b = rtb-IDbb
          us-east-1c = rtb-IDcc
        }
        cidr_blocks = {
          us-east-1a = "10.0.3.0/24"
          us-east-1b = "10.0.4.0/24"
          us-east-1c = "10.0.5.0/24"
        }
      }
    }
}
```

### Hub and Spoke with Inspection VPC

The use case covers the creation of a centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway, with the idea of managing the traffic inspection at scale. When using the key `centralized_inspection_without_egress` it is supposed that the Inspection VPC created is only used to place the AWS Transit Gateway ENIs and the firewall endpoints. The image below shows an example of the architecture, routing configuration, and traffic flow.

![Central Inspection VPC - Architecture diagram](./images/centralized\_vpc.png)

An example of the definition of this routing configuration is the following one:

```hcl
routing_configuration = {
    centralized_inspection_without_egress = {
      tgw_route_tables = {
        us-east-1a = rtb-IDa
        us-east-1b = rtb-IDb
        us-east-1c = rtb-IDc
      }
    }
}
```

### Hub and Spoke with Inspection VPC (with egress traffic)

The use case covers the creation of a centralized Inspection VPC in a Hub and Spoke architecture with AWS Transit Gateway, with the idea of managing the traffic inspection at scale. When using the key `centralized_inspection_with_egress` it is supposed that the Inspection VPC also has access to the Internet, to centralize inspection and egress traffic at the same time. The image below shows an example of the architecture, routing configuration, and traffic flow.

![Central Inspection VPC with Egress traffic - Architecture diagram](./images/centralized\_vpc\_with\_egress.png)

An example of the definition of this routing configuration is the following one:

```hcl
routing_configuration = {
    centralized_inspection_with_egress = {
      tgw_route_tables = {
        us-east-1a = rtb-IDa
        us-east-1b = rtb-IDb
        us-east-1c = rtb-IDc
      }
      public_route_tables = {
        us-east-1a = rtb-IDaa
        us-east-1b = rtb-IDbb
        us-east-1c = rtb-IDcc
      }
      network_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/24"]
    }
}
```

## References

- Reference Architecture: [Inspection Deployment models with with AWS Network Firewall](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/inspection-deployment-models-with-AWS-network-firewall-ra.pdf)
- Blog post: [Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/)
- Blog post: [Deployment models for AWS Network Firewall with VPC routing enhancements](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall-with-vpc-routing-enhancements/)

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
| <a name="module_central_inspection_with_egress"></a> [central\_inspection\_with\_egress](#module\_central\_inspection\_with\_egress) | ./modules/central_inspection_with_egress | n/a |
| <a name="module_routing_enhacement"></a> [routing\_enhacement](#module\_routing\_enhacement) | ./modules/routing_enhacement | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall.anfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_route.igw_route_table_to_protected_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.protected_route_table_to_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.tgw_to_firewall_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.tgw_to_firewall_endpoint_without_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_firewall_name"></a> [network\_firewall\_name](#input\_network\_firewall\_name) | Name to give the AWS Network Firewall resource created. | `string` | n/a | yes |
| <a name="input_network_firewall_policy"></a> [network\_firewall\_policy](#input\_network\_firewall\_policy) | ARN of the firewall policy to include in AWS Network Firewall. | `string` | n/a | yes |
| <a name="input_number_azs"></a> [number\_azs](#input\_number\_azs) | Number of Availability Zones to place the Network Firewall endpoints. | `number` | n/a | yes |
| <a name="input_routing_configuration"></a> [routing\_configuration](#input\_routing\_configuration) | Configuration of the routing desired in the VPC. Depending the type of VPC, the information to provide is different. The type of VPCs supported are: `single_vpc`, `single_vpc_routing_enhacement`, `centralized_inspection_without_egress`, and `centralized_inspection_with_egress`. **Only one key (option) can be defined**<br>More information about the differences between each of the VPC types can be checked in the README. Example definition of each type (supposing us-east-1 as AWS Region):<pre>routing_configuration = { <br>  single_vpc = { <br>    igw_route_table = rtb-ID<br>    route_tables = { <br>      us-east-1a = rtb-IDa<br>      us-east-1b = rtb-IDb<br>      us-east-1c = rtb-IDc<br>    }<br>    cidr_blocks = {<br>      us-east-1a = "10.0.0.0/24"<br>      us-east-1b = "10.0.1.0/24"<br>      us-east-1c = "10.0.2.0/24"<br>    }<br>  }<br>}<br><br>routing_configuration = { <br>  single_vpc_routing_enhacement = { <br>    workload_to_db = { <br>      route_tables = { <br>        us-east-1a = rtb-IDa<br>        us-east-1b = rtb-IDb<br>        us-east-1c = rtb-IDc<br>      }<br>      cidr_blocks = {<br>        us-east-1a = "10.0.0.0/24"<br>        us-east-1b = "10.0.1.0/24"<br>        us-east-1c = "10.0.2.0/24"<br>      }<br>    }<br>    db_to_workload = {<br>      route_tables = { <br>        us-east-1a = rtb-IDaa<br>        us-east-1b = rtb-IDbb<br>        us-east-1c = rtb-IDcc<br>      }<br>      cidr_blocks = {<br>        us-east-1a = "10.0.3.0/24"<br>        us-east-1b = "10.0.4.0/24"<br>        us-east-1c = "10.0.5.0/24"<br>      }<br>    }<br>  }<br>}<br><br>routing_configuration = {<br>  centralized_inspection_without_egress = { <br>    tgw_route_tables = { <br>      us-east-1a = rtb-IDa<br>      us-east-1b = rtb-IDb<br>      us-east-1c = rtb-IDc<br>    }<br>  }<br>}<br><br>routing_configuration = {<br>  centralized_inspection_with_egress = {<br>    tgw_route_tables = { <br>      us-east-1a = rtb-IDa<br>      us-east-1b = rtb-IDb<br>      us-east-1c = rtb-IDc<br>    }<br>    public_route_tables = {<br>      us-east-1a = rtb-IDaa<br>      us-east-1b = rtb-IDbb<br>      us-east-1c = rtb-IDcc<br>    }<br>    network_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/24"]<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to place the Network Firewall endpoints. | `string` | n/a | yes |
| <a name="input_vpc_subnets"></a> [vpc\_subnets](#input\_vpc\_subnets) | Map of subnet IDs to place the Network Firewall endpoints. The expected format of the map is the Availability Zone as key, and the ID of the subnet as value.<br>Example (supposing us-east-1 as AWS Region):<pre>vpc_subnets = {<br>    us-east-1a = subnet-IDa<br>    us-east-1b = subnet-IDb<br>    us-east-1c = subnet-IDc<br>}</pre> | `map(string)` | n/a | yes |
| <a name="input_network_firewall_policy_change_protection"></a> [network\_firewall\_policy\_change\_protection](#input\_network\_firewall\_policy\_change\_protection) | A boolean flag indicating whether it is possible to change the associated firewall policy. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_network_firewall_subnet_change_protection"></a> [network\_firewall\_subnet\_change\_protection](#input\_network\_firewall\_subnet\_change\_protection) | A boolean flag indicating whether it is possible to change the associated subnet(s). Defaults to `false`. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_network_firewall"></a> [aws\_network\_firewall](#output\_aws\_network\_firewall) | AWS Network Firewall. |
<!-- END_TF_DOCS -->