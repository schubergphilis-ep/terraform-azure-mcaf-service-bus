output "id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "The resource ID of the Service Bus namespace."
}

output "name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "The name of the Service Bus namespace."
}

output "endpoint" {
  value       = azurerm_servicebus_namespace.this.endpoint
  description = "The FQDN of the Service Bus namespace (e.g. myns.servicebus.windows.net)."
}

output "identity" {
  value = var.system_assigned_identity_enabled ? {
    principal_id = azurerm_servicebus_namespace.this.identity[0].principal_id
    tenant_id    = azurerm_servicebus_namespace.this.identity[0].tenant_id
  } : null
  description = "The system-assigned managed identity principal and tenant IDs. Null when system-assigned identity is disabled."
}

output "user_assigned_identity_ids" {
  value       = var.user_assigned_identities
  description = "List of user-assigned managed identity resource IDs assigned to the namespace. Empty when no user-assigned identities are configured."
}

output "queue_ids" {
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
  description = "Map of queue name to queue resource ID."
}

output "topic_ids" {
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
  description = "Map of topic name to topic resource ID."
}

output "subscription_ids" {
  value       = { for k, v in azurerm_servicebus_subscription.this : k => v.id }
  description = "Map of 'topic/subscription' key to subscription resource ID."
}

output "subscription_rule_ids" {
  value       = { for k, v in azurerm_servicebus_subscription_rule.this : k => v.id }
  description = "Map of 'topic/subscription/rule' key to subscription rule resource ID."
}
