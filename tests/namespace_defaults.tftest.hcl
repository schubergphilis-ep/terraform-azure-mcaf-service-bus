mock_provider "azurerm" {}

variables {
  name                = "test-sbns"
  location            = "westeurope"
  resource_group_name = "test-rg"
}

run "namespace_sku_defaults_to_premium" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.sku == "Premium"
    error_message = "sku must default to Premium"
  }
}

run "namespace_disables_local_auth_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.local_auth_enabled == false
    error_message = "local_auth_enabled must default to false"
  }
}

run "namespace_enforces_tls12_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.minimum_tls_version == "1.2"
    error_message = "minimum_tls_version must default to 1.2"
  }
}

run "namespace_disables_public_access_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.public_network_access_enabled == false
    error_message = "public_network_access_enabled must default to false"
  }
}

run "namespace_sets_capacity_to_1_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.capacity == 1
    error_message = "capacity must default to 1 messaging unit"
  }
}

run "namespace_sets_partitions_to_1_by_default" {
  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.this.premium_messaging_partitions == 1
    error_message = "premium_messaging_partitions must default to 1 for fault tolerance"
  }
}

run "namespace_rejects_invalid_sku" {
  command = plan

  variables {
    sku = "Enterprise"
  }

  expect_failures = [var.sku]
}

run "namespace_enables_system_identity_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_servicebus_namespace.this.identity) > 0
    error_message = "system-assigned identity must be enabled by default"
  }

  assert {
    condition     = azurerm_servicebus_namespace.this.identity[0].type == "SystemAssigned"
    error_message = "identity type must be SystemAssigned by default"
  }
}
