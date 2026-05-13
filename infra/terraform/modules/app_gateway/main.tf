data "azurerm_application_gateway" "existing" {
  name                = "agw-secureflow"
  resource_group_name = var.resource_group_name
}

data "azurerm_public_ip" "existing_appgw" {
  name                = "pip-appgw"
  resource_group_name = var.resource_group_name
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = length(var.threat_intel_block_ips) > 0 ? [1] : []

    content {
      name      = "BlockThreatIntelIPs"
      priority  = 50
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }

        operator           = "IPMatch"
        negation_condition = false
        match_values       = var.threat_intel_block_ips
      }
    }
  }

  custom_rules {
    name                 = "RateLimitLayer7Flood"
    priority             = 60
    rule_type            = "RateLimitRule"
    action               = "Block"
    rate_limit_duration  = "OneMin"
    rate_limit_threshold = 120
    group_rate_limit_by  = "ClientAddr"

    match_conditions {
      match_variables {
        variable_name = "RequestUri"
      }

      operator           = "Regex"
      negation_condition = false
      match_values       = [".*"]
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}
