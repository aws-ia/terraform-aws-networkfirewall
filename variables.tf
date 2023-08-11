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
  default     = {}
  description = <<-EOF
  Configuration of the routing desired in the VPC. Depending the VPC type, the information to provide is different. The configuration types supported are: `single_vpc`, `intra_vpc_inspection`, `centralized_inspection_without_egress`, and `centralized_inspection_with_egress`. **Only one key (option) can be defined**
  More information about the differences between each the routing configurations (and examples) can be checked in the README. 
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
    error_message = "When configuring the inspecton routing in a central Inspection VPC (without egress traffic), the valid key values are: \"connectivity_subnet_route_tables\", \"cwan_subnet_route_tables\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.centralized_inspection_without_egress, {})), [
      "connectivity_subnet_route_tables"
    ])) == 0
  }

  # Valid keys in Central Inspection VPC (with egress traffic)
  validation {
    error_message = "When configuring the inspecton routing in a central Inspection VPC (with egress traffic), the valid key values are: \"connectivity_subnet_route_tables\", \"public_route_tables\", \"network_cidr_blocks\"."
    condition = length(setsubtract(keys(try(var.routing_configuration.centralized_inspection_with_egress, {})), [
      "connectivity_subnet_route_tables",
      "public_subnet_route_tables",
      "network_cidr_blocks"
    ])) == 0
  }
}

# AWS Network Firewall logging configuration
variable "logging_configuration" {
  type        = any
  default     = {}
  description = <<-EOF
  Configuration of the logging desired for the Network Firewall. You can configure at most 2 destinations for your logs, 1 for FLOW logs and 1 for ALERT logs.
  More information about the format of the variable (and examples) can be found in the README.
  ```
  EOF

  # You cannot specify other keys than the ones allowed
  validation {
    error_message = "Valid keys in var.logging_configuration: \"flow_log\", \"alert_log\"."
    condition = length(
      setsubtract(
        setunion(keys(var.logging_configuration), ["flow_log", "alert_log"]),
        ["flow_log", "alert_log"]
      )
    ) == 0
  }

  # You cannot specify other keys than the logging destination supported
  validation {
    error_message = "Valid keys within \"flow_log\", \"alert_log\" are: \"s3_bucket\", \"cloudwatch_logs\", \"kinesis_firehose\"."
    condition = length(
      setsubtract(
        setunion(distinct(flatten([for c in var.logging_configuration : keys(c)])), ["s3_bucket", "cloudwatch_logs", "kinesis_firehose"]),
        ["s3_bucket", "cloudwatch_logs", "kinesis_firehose"]
      )
    ) == 0
  }

  # You cannot specify other keys than the supported by S3
  validation {
    error_message = "Valid keys within \"s3_bucket\", are: \"bucketName\", \"logPrefix\"."
    condition = length(
      setsubtract(
        setunion(distinct(flatten([for c in var.logging_configuration : keys(try(c.s3_bucket, {}))])), ["bucketName", "logPrefix"]),
        ["bucketName", "logPrefix"]
      )
    ) == 0
  }

  # You cannot specify other keys than the supported by CWLogs
  validation {
    error_message = "Valid keys within \"cloudwatch_logs\", are: \"logGroupName\"."
    condition = length(
      setsubtract(
        setunion(distinct(flatten([for c in var.logging_configuration : keys(try(c.cloudwatch_logs, {}))])), ["logGroupName"]),
        ["logGroupName"]
      )
    ) == 0
  }

  # You cannot specify other keys than the supported by Kinesis Firehose
  validation {
    error_message = "Valid keys within \"kinesis_firehose\", are: \"deliveryStreamName\"."
    condition = length(
      setsubtract(
        setunion(distinct(flatten([for c in var.logging_configuration : keys(try(c.kinesis_firehose, {}))])), ["deliveryStreamName"]),
        ["deliveryStreamName"]
      )
    ) == 0
  }
}

