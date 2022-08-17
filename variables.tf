# --- root/variables.tf ---

# Variables related to AWS Network Firewall resource
variable "network_firewall_name" {
  type        = string
  description = "Name to give the AWS Network Firewall resource created."
}

variable "network_firewall_policy" {
  type        = string
  description = "ARN of the firewall policy to include in AWS Network Firewall."
}

variable "network_firewall_policy_change_protection" {
  type        = bool
  description = "A boolean flag indicating whether it is possible to change the associated firewall policy. Defaults to `false`."

  default = false
}

variable "network_firewall_subnet_change_protection" {
  type        = bool
  description = "A boolean flag indicating whether it is possible to change the associated subnet(s). Defaults to `false`."

  default = false
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
  default     = {}
}

# Variables related to the VPC, subnets, and routing configuration where AWS Network Firewall is placed.
variable "vpc_id" {
  type        = string
  description = "VPC ID to place the Network Firewall endpoints."
}

variable "number_azs" {
  type        = number
  description = "Number of Availability Zones to place the Network Firewall endpoints."
}

variable "vpc_subnets" {
  type        = map(string)
  description = <<-EOF
  Map of subnet IDs to place the Network Firewall endpoints. The expected format of the map is the Availability Zone as key, and the ID of the subnet as value.
  Example (supposing us-east-1 as AWS Region): 
  ```
  vpc_subnets = {
      us-east-1a = subnet-IDa
      us-east-1b = subnet-IDb
      us-east-1c = subnet-IDc
  }
  ```
EOF
}

variable "routing_configuration" {
  type        = any
  description = <<-EOF
  Configuration of the routing desired in the VPC. Depending the type of VPC, the information to provide is different. The type of VPCs supported are: `single_vpc`, `intra_vpc_inspection`, `centralized_inspection_without_egress`, and `centralized_inspection_with_egress`. **Only one key (option) can be defined**
  More information about the differences between each of the VPC types can be checked in the README. Example definition of each type (supposing us-east-1 as AWS Region): 
  ```
  routing_configuration = { 
    single_vpc = { 
      igw_route_table = rtb-ID
      protected_subnet_route_tables = { 
        us-east-1a = rtb-IDa
        us-east-1b = rtb-IDb
        us-east-1c = rtb-IDc
      }
      protected_subnet_cidr_blocks = {
        us-east-1a = "10.0.0.0/24"
        us-east-1b = "10.0.1.0/24"
        us-east-1c = "10.0.2.0/24"
      }
    }
  }

  routing_configuration = { 
    intra_vpc_inspection = {
      number_routes = 2
      routes = {
        { 
          source_subnet_route_tables = { 
            us-east-1a = rtb-IDa
            us-east-1b = rtb-IDb
            us-east-1c = rtb-IDc
          }
          destination_subnet_cidr_blocks = {
            us-east-1a = "10.0.0.0/24"
            us-east-1b = "10.0.1.0/24"
            us-east-1c = "10.0.2.0/24"
          }
        },
        {
          source_subnet_route_tables = { 
            us-east-1a = rtb-IDaa
            us-east-1b = rtb-IDbb
            us-east-1c = rtb-IDcc
          }
          destination_subnet_cidr_blocks = {
            us-east-1a = "10.0.3.0/24"
            us-east-1b = "10.0.4.0/24"
            us-east-1c = "10.0.5.0/24"
          }
        }
      }
    }
  }

  routing_configuration = {
    centralized_inspection_without_egress = { 
      tgw_subnet_route_tables = { 
        us-east-1a = rtb-IDa
        us-east-1b = rtb-IDb
        us-east-1c = rtb-IDc
      }
    }
  }

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
EOF

  # Valid keys in var.routing_configuration
  validation {
    error_message = "Valid keys in var.routing_configuration: \"single_vpc\", \"single_vpc_intra_subnet\", \"centralized_inspection_without_egress\", \"centralized_inspection_with_egress\"."
    condition = length(setsubtract(keys(try(var.routing_configuration, {})), [
      "single_vpc",
      "intra_vpc_inspection",
      "centralized_inspection_without_egress",
      "centralized_inspection_with_egress"
    ])) == 0
  }

  # Only one key is allowed
  validation {
    error_message = "Only 1 definition of the routing configuration is allowed."
    condition     = (length(keys(try(var.routing_configuration, {})))) == 1
  }

  # Valid keys in Single VPC (Ingress/Egress Routing Inspection)
  validation {
    error_message = "When configuring the inspecton routing in a single VPC, the valid key values are: \"igw_route_table\", \"protected_subnet_route_tables\", \"protected_subnet_cidr_blocks\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.single_vpc, {})), [
      "igw_route_table",
      "protected_subnet_route_tables",
      "protected_subnet_cidr_blocks"
    ])) == 0
  }

  # Valid keys in Intra-VPC Inspection
  validation {
    error_message = "When configuring the intra-VPC inspecton routing, the valid key values are: \"number_routes\", \"routes\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.intra_vpc_inspection, {})), [
      "number_routes",
      "routes"
    ])) == 0
  }

  # Valid keys in Intra-VPC Inspection Routes
  validation {
    error_message = "When configuring the routes in intra-VPC inspection routing, the valid key values are: \"source_subnet_route_tables\", \"destination_subnet_cidr_blocks\"."
    condition = alltrue([
      for c in try(var.routing_configuration.intra_vpc_inspection.routes, {}) : length(setsubtract(keys(try(c, {})), [
        "source_subnet_route_tables",
        "destination_subnet_cidr_blocks"
      ])) == 0
    ])
  }

  # Valid keys in Central Inspection VPC (without egress traffic)
  validation {
    error_message = "When configuring the inspecton routing in a central Inspection VPC (without egress traffic), the valid key values are: \"tgw_subnet_route_tables\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.centralized_inspection_without_egress, {})), [
      "tgw_subnet_route_tables"
    ])) == 0
  }

  # Valid keys in Central Inspection VPC (with egress traffic)
  validation {
    error_message = "When configuring the inspecton routing in a central Inspection VPC (with egress traffic), the valid key values are: \"tgw_route_tables\", \"public_route_tables\", \"network_cidr_blocks\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.centralized_inspection_with_egress, {})), [
      "tgw_subnet_route_tables",
      "public_subnet_route_tables",
      "network_cidr_blocks"
    ])) == 0
  }
}

