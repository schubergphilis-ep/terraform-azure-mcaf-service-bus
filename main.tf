resource "azurerm_servicebus_namespace" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.sku == "Premium" ? var.capacity : null
  local_auth_enabled            = var.local_auth_enabled
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  premium_messaging_partitions  = var.sku == "Premium" ? var.premium_messaging_partitions : null

  dynamic "identity" {
    for_each = coalesce(
      local.identity_system_assigned_user_assigned,
      local.identity_system_assigned,
      local.identity_user_assigned,
      {}
    )

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  network_rule_set {
    default_action           = var.network_rule_set.default_action
    trusted_services_allowed = var.network_rule_set.trusted_services_allowed
    ip_rules                 = var.network_rule_set.ip_rules

    dynamic "network_rules" {
      for_each = var.network_rule_set.network_rules

      content {
        subnet_id                            = network_rules.value.subnet_id
        ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
      }
    }
  }

  tags = merge(
    var.tags,
    { "Resource Type" = "Service Bus Namespace" }
  )
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = each.key
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "cmk" {
  count = var.cmk != null ? 1 : 0

  scope                = var.cmk.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id = (
    var.cmk.user_assigned_identity_id != null
    ? var.cmk.user_assigned_identity_id
    : azurerm_servicebus_namespace.this.identity[0].principal_id
  )

  lifecycle {
    precondition {
      condition = (
        var.cmk == null ||
        var.cmk.user_assigned_identity_id != null ||
        var.system_assigned_identity_enabled
      )
      error_message = "When cmk is set and user_assigned_identity_id is not provided, system_assigned_identity_enabled must be true so the system-assigned identity can access Key Vault."
    }
  }
}

resource "azurerm_servicebus_namespace_customer_managed_key" "this" {
  count = var.cmk != null ? 1 : 0

  namespace_id     = azurerm_servicebus_namespace.this.id
  key_vault_key_id = var.cmk.key_vault_key_id

  depends_on = [azurerm_role_assignment.cmk]
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_delivery_count                      = each.value.max_delivery_count
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  default_message_ttl                     = each.value.default_message_ttl
  lock_duration                           = each.value.lock_duration
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.requires_duplicate_detection ? each.value.duplicate_detection_history_time_window : null
  requires_session                        = each.value.requires_session
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  batched_operations_enabled              = each.value.batched_operations_enabled
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  forward_to                              = each.value.forward_to
  forward_dead_lettered_messages_to       = each.value.forward_dead_lettered_messages_to
}
