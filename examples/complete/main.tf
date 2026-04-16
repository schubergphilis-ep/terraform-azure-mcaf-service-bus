module "servicebus" {
  source = "../../"

  name                = "myapp-sbns-complete"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Network
  private_endpoints = {
    "primary" = {
      subnet_id            = var.private_endpoint_subnet_id
      private_dns_zone_ids = [var.servicebus_private_dns_zone_id]
    }
  }

  network_rule_set = {
    default_action           = "Deny"
    trusted_services_allowed = true
  }

  # Access
  role_assignments = {
    "sender" = {
      role_definition_name = "Azure Service Bus Data Sender"
      principal_id         = var.sender_principal_id
    }
  }

  # Queues
  queues = {
    "orders" = {
      max_delivery_count           = 5
      requires_duplicate_detection = true
      default_message_ttl          = "PT1H"
    }
    "deadletter-reprocessing" = {}
  }

  # Topics with subscriptions
  topics = {
    "domain-events" = {
      requires_duplicate_detection = true
      subscriptions = {
        "payments" = {
          max_delivery_count = 5
          rules = {
            "orders-only" = {
              filter_type = "SqlFilter"
              sql_filter  = "eventType = 'OrderPlaced'"
            }
          }
        }
        "notifications" = {
          rules = {
            "high-value" = {
              filter_type = "CorrelationFilter"
              correlation_filter = {
                label      = "high-value"
                properties = { source = "orders" }
              }
            }
          }
        }
        "audit" = { forward_to = "deadletter-reprocessing" }
      }
    }
  }

  tags = {
    Environment = "production"
    Module      = "terraform-azure-mcaf-servicebus"
  }
}

output "namespace_id" {
  value = module.servicebus.id
}

output "namespace_endpoint" {
  value = module.servicebus.endpoint
}
