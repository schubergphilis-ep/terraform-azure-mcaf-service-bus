mock_provider "azurerm" {}

variables {
  name                = "test-sbns"
  location            = "westeurope"
  resource_group_name = "test-rg"

  queues = {
    "orders" = {}
  }
}

run "queue_created_with_defaults" {
  command = plan

  assert {
    condition     = azurerm_servicebus_queue.this["orders"].name == "orders"
    error_message = "queue name must match map key"
  }

  assert {
    condition     = azurerm_servicebus_queue.this["orders"].max_delivery_count == 10
    error_message = "max_delivery_count must default to 10"
  }

  assert {
    condition     = azurerm_servicebus_queue.this["orders"].dead_lettering_on_message_expiration == true
    error_message = "dead_lettering_on_message_expiration must default to true"
  }

  assert {
    condition     = azurerm_servicebus_queue.this["orders"].batched_operations_enabled == true
    error_message = "batched_operations_enabled must default to true"
  }
}

run "no_queues_creates_no_queue_resources" {
  command = plan

  variables {
    queues = {}
  }

  assert {
    condition     = length(azurerm_servicebus_queue.this) == 0
    error_message = "no queues variable must produce no queue resources"
  }
}
