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
