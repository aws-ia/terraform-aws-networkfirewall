# --- examples/single_vpc/modules/iam_kms/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "aws_region" {
  type        = string
  description = "AWS Region indicated in the variables - where the resources are created."
}