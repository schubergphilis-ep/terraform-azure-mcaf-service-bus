mock_provider "azurerm" {}

variables {
  name                = "test-sbns"
  location            = "westeurope"
  resource_group_name = "test-rg"

  topics = {
    "events" = {
      subscriptions = {
        "payments" = {
          rules = {
            "red-only" = {
              filter_type = "SqlFilter"
              sql_filter  = "colour = 'red'"
            }
          }
        }
        "notifications" = {
          rules = {
            "high-priority" = {
              filter_type = "CorrelationFilter"
              correlation_filter = {
                label = "high"
              }
            }
          }
        }
        "audit" = {}
      }
    }
  }
}

run "sql_filter_rule_created_with_correct_key" {
  command = plan

  assert {
    condition     = contains(keys(azurerm_servicebus_subscription_rule.this), "events/payments/red-only")
    error_message = "rule key must be 'topic/subscription/rule'"
  }
}

run "sql_filter_rule_has_correct_filter_type" {
  command = plan

  assert {
    condition     = azurerm_servicebus_subscription_rule.this["events/payments/red-only"].filter_type == "SqlFilter"
    error_message = "filter_type must be SqlFilter"
  }
}

run "sql_filter_rule_has_correct_expression" {
  command = plan

  assert {
    condition     = azurerm_servicebus_subscription_rule.this["events/payments/red-only"].sql_filter == "colour = 'red'"
    error_message = "sql_filter must match the specified expression"
  }
}

run "correlation_filter_rule_created" {
  command = plan

  assert {
    condition     = contains(keys(azurerm_servicebus_subscription_rule.this), "events/notifications/high-priority")
    error_message = "correlation filter rule must be created with correct key"
  }
}

run "correlation_filter_rule_has_correct_filter_type" {
  command = plan

  assert {
    condition     = azurerm_servicebus_subscription_rule.this["events/notifications/high-priority"].filter_type == "CorrelationFilter"
    error_message = "filter_type must be CorrelationFilter"
  }
}

run "subscription_without_rules_creates_no_rule_resources" {
  command = plan

  assert {
    condition     = !contains(keys(azurerm_servicebus_subscription_rule.this), "events/audit/")
    error_message = "subscription with no rules must produce no rule resources"
  }
}

run "no_topics_creates_no_rule_resources" {
  command = plan

  variables {
    topics = {}
  }

  assert {
    condition     = length(azurerm_servicebus_subscription_rule.this) == 0
    error_message = "no topics must produce no subscription rule resources"
  }
}

run "sql_filter_with_action" {
  command = plan

  variables {
    topics = {
      "events" = {
        subscriptions = {
          "payments" = {
            rules = {
              "red-set-priority" = {
                filter_type = "SqlFilter"
                sql_filter  = "colour = 'red'"
                action      = "SET sys.label = 'urgent'"
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_servicebus_subscription_rule.this["events/payments/red-set-priority"].action == "SET sys.label = 'urgent'"
    error_message = "action must be set when specified"
  }
}
