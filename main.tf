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

  tags = merge(
    var.tags,
    tomap({
      "Resource Type" = "Service Bus Namespace"
    })
  )
}
