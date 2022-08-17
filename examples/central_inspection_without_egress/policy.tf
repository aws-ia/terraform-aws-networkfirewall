# --- examples/central_inspection_without_egress/policy.tf ---

resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy-${var.identifier}"

  firewall_policy {

    # Stateless configuration
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.drop_remote.arn
    }

    # Stateful configuration
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.allow_icmp_1_to_2.arn
    }
    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.allow_icmp_2_to_3.arn
    }
  }
}

# Stateless Rule Group - Dropping any SSH or RDP connection
resource "aws_networkfirewall_rule_group" "drop_remote" {
  capacity = 2
  name     = "drop-remote-${var.identifier}"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {

        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 22
                to_port   = 22
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }

        stateless_rule {
          priority = 2
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [27]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

# Stateful Rule Group 1 - Allowing ICMP traffic from Spoke VPC 1 to 2
resource "aws_networkfirewall_rule_group" "allow_icmp_1_to_2" {
  capacity = 100
  name     = "allow-icmp-12-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "SPOKE1"
        ip_set {
          definition = [var.vpcs.spoke-vpc-1.cidr_block]
        }
      }
      ip_sets {
        key = "SPOKE2"
        ip_set {
          definition = [var.vpcs.spoke-vpc-2.cidr_block]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      pass icmp $SPOKE1 any -> $SPOKE2 any (msg: "Allowing ICMP packets from Spoke VPC 1 to 2"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# Stateful Rule Group 2 - Allowing ICMP traffic from Spoke VPC 2 to 3
resource "aws_networkfirewall_rule_group" "allow_icmp_2_to_3" {
  capacity = 100
  name     = "allow-icmp-23-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "SPOKE2"
        ip_set {
          definition = [var.vpcs.spoke-vpc-2.cidr_block]
        }
      }
      ip_sets {
        key = "SPOKE3"
        ip_set {
          definition = [var.vpcs.spoke-vpc-3.cidr_block]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      pass icmp $SPOKE2 any -> $SPOKE3 any (msg: "Allowing ICMP packets from Spoke VPC 2 to 3"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}
