# Changes from 0.x to 1.x

* The input for the route tables of those subnets used for inter-VPC connectivity (where either AWS Transit Gateway or AWS Cloud WAN ENIs are placed) was renamed from `tgw_subnet_route_table` to `connectivity_subnet_route_table` to avoid confusion if those subnets where used for Cloud WAN attachments. This change applies in two routing configurations: `centralized_inspection_without_egress` and `centralized_inspection_with_egress`.

# Required Changes to Make

## Changes in routing configuration `centralized_inspection_without_egress`

Before:

```hcl
routing_configuration = {
  centralized_inspection_without_egress = {
    tgw_subnet_route_tables = {...}
  }
}
```

After:

```hcl
routing_configuration = {
  centralized_inspection_without_egress = {
    connectivity_subnet_route_tables = {...}
  }
}
```

## Changes in routing configuration `centralized_inspection_with_egress`

Before:

```hcl
routing_configuration = {
  centralized_inspection_with_egress = {
    tgw_subnet_route_tables    = {...}
    public_subnet_route_tables = {...}
    network_cidr_blocks        = [...]
  }
}
```

After:

```hcl
routing_configuration = {
  centralized_inspection_with_egress = {
    connectivity_subnet_route_tables = {...}
    public_subnet_route_tables       = {...}
    network_cidr_blocks              = [...]
  }
}
```

# Moved Resources

With this change in the new version, the VPC routes resources from the connectivity subnets (Transit Gateway or Cloud WAN's core network) to the Network Firewall endpoints change - creating a potential re-creation of the resources when you upgrade the module version.

To avoid the recreation of resources, we use [moved blocks](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring) to update the Terraform state with the new names. You can find the moved blocks declaration in the **moved.tf** file.
