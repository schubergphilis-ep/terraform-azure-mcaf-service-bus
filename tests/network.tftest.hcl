mock_provider "azurerm" {}

variables {
  name                = "test-sbns"
  location            = "westeurope"
  resource_group_name = "test-rg"
}

run "network_rule_set_denies_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.network_rule_set[0].default_action == "Deny"
    error_message = "default_action must be Deny"
  }
}

run "network_rule_set_allows_trusted_services_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.network_rule_set[0].trusted_services_allowed == true
    error_message = "trusted_services_allowed must default to true"
  }
}

run "network_rule_set_custom_ip_rule" {
  command = plan

  variables {
    network_rule_set = {
      ip_rules = ["1.2.3.4/32"]
    }
  }

  assert {
    condition     = contains(tolist(azurerm_servicebus_namespace.this.network_rule_set[0].ip_rules), "1.2.3.4/32")
    error_message = "ip_rules must contain the specified CIDR"
  }
}
