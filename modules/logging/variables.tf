# --- modules/logging/variables.tf ---

variable "firewall_arn" {
  type        = string
  description = "The ARN of the Network Firewall on which logging will be configured."
}

variable "logging_configuration" {
  type        = any
  description = "The logging configuration. See top module for more details."
}
