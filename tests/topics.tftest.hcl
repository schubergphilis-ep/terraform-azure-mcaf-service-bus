mock_provider "azurerm" {}

variables {
  name                = "test-sbns"
  location            = "westeurope"
  resource_group_name = "test-rg"

  topics = {
    "events" = {
      subscriptions = {
        "payments"      = {}
        "notifications" = { max_delivery_count = 5 }
      }
    }
  }
}

run "topic_created" {
  command = plan

  assert {
    condition     = azurerm_servicebus_topic.this["events"].name == "events"
    error_message = "topic name must match map key"
  }
}

run "subscriptions_created_with_correct_keys" {
  command = plan

  assert {
    condition     = contains(keys(azurerm_servicebus_subscription.this), "events/payments")
    error_message = "subscription key must be 'topic/subscription'"
  }

  assert {
    condition     = contains(keys(azurerm_servicebus_subscription.this), "events/notifications")
    error_message = "subscription key must be 'topic/subscription'"
  }
}

run "subscription_inherits_defaults" {
  command = plan

  assert {
    condition     = azurerm_servicebus_subscription.this["events/payments"].dead_lettering_on_message_expiration == true
    error_message = "dead_lettering_on_message_expiration must default to true"
  }

  assert {
    condition     = azurerm_servicebus_subscription.this["events/payments"].dead_lettering_on_filter_evaluation_error == true
    error_message = "dead_lettering_on_filter_evaluation_error must default to true"
  }
}

run "subscription_respects_override" {
  command = plan

  assert {
    condition     = azurerm_servicebus_subscription.this["events/notifications"].max_delivery_count == 5
    error_message = "max_delivery_count must respect the caller's value"
  }
}

run "no_topics_creates_no_topic_or_subscription_resources" {
  command = plan

  variables {
    topics = {}
  }

  assert {
    condition     = length(azurerm_servicebus_topic.this) == 0
    error_message = "no topics must produce no topic resources"
  }

  assert {
    condition     = length(azurerm_servicebus_subscription.this) == 0
    error_message = "no topics must produce no subscription resources"
  }
}
