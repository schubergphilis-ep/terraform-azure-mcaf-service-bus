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

  tags = merge(
    var.tags,
    tomap({
      "Resource Type" = "Service Bus Namespace"
    })
  )
}
