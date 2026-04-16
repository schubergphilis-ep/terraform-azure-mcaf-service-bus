variable "name" {
  type        = string
  description = "Name of the Service Bus namespace."
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region in which to deploy the Service Bus namespace."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the Service Bus namespace into."
  nullable    = false
}

variable "sku" {
  type        = string
  default     = "Premium"
  description = "The SKU of the Service Bus namespace. Defaults to Premium, which is required for private endpoints, zone redundancy, CMK encryption, and auto-scaling."

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The sku must be one of 'Basic', 'Standard', or 'Premium'."
  }
}

variable "capacity" {
  type        = number
  default     = 1
  description = "The number of messaging units for Premium tier. Valid values are 1, 2, 4, 8, and 16. Ignored for Basic and Standard tiers."

  validation {
    condition     = contains([1, 2, 4, 8, 16], var.capacity)
    error_message = "The capacity must be one of 1, 2, 4, 8, or 16."
  }
}

variable "local_auth_enabled" {
  type        = bool
  default     = false
  description = "Whether SAS key authentication is enabled. Defaults to false to enforce Entra ID. Set to true only for legacy clients that cannot use OAuth 2.0."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version for client connections. Defaults to 1.2."

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "The minimum_tls_version must be one of '1.0', '1.1', or '1.2'."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether public network access is enabled. Defaults to false."
}

variable "premium_messaging_partitions" {
  type        = number
  default     = 1
  description = "Number of messaging partitions for the Premium namespace. 0 disables partitioning. Valid values: 0, 1, 2, 4. Defaults to 1 for fault tolerance."

  validation {
    condition     = contains([0, 1, 2, 4], var.premium_messaging_partitions)
    error_message = "The premium_messaging_partitions must be 0, 1, 2, or 4."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to all resources created by this module."
}

variable "system_assigned_identity_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable a system-assigned managed identity. Defaults to true."
}

variable "user_assigned_identities" {
  type        = list(string)
  default     = []
  description = "List of user-assigned managed identity resource IDs to assign to the namespace."
}

variable "network_rule_set" {
  type = object({
    default_action           = optional(string, "Deny")
    trusted_services_allowed = optional(bool, true)
    ip_rules                 = optional(set(string), [])
    network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Network rule set configuration. This block is always applied — the module enforces a deny-by-default posture. Pass `{}` to accept all defaults.

- `default_action` - Default action when no rule matches. Defaults to `"Deny"`.
- `trusted_services_allowed` - Allow Azure services (Functions, Logic Apps, Event Grid) to bypass rules. Defaults to `true`.
- `ip_rules` - Set of public IP/CIDR ranges allowed to connect. Defaults to empty.
- `network_rules` - List of VNet subnet rules.
  - `subnet_id` - Resource ID of the subnet.
  - `ignore_missing_vnet_service_endpoint` - Ignore if VNet service endpoint is missing. Defaults to `false`.
DESCRIPTION
}

variable "topics" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    max_message_size_in_kilobytes           = optional(number, null)
    default_message_ttl                     = optional(string, null)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, "PT10M")
    support_ordering                        = optional(bool, false)
    auto_delete_on_idle                     = optional(string, null)

    subscriptions = optional(map(object({
      max_delivery_count                        = optional(number, 10)
      lock_duration                             = optional(string, "PT1M")
      requires_session                          = optional(bool, false)
      default_message_ttl                       = optional(string, null)
      dead_lettering_on_message_expiration      = optional(bool, true)
      dead_lettering_on_filter_evaluation_error = optional(bool, true)
      batched_operations_enabled                = optional(bool, true)
      forward_to                                = optional(string, null)
      forward_dead_lettered_messages_to         = optional(string, null)
      auto_delete_on_idle                       = optional(string, null)
      rules = optional(map(object({
        filter_type = string
        sql_filter  = optional(string, null)
        action      = optional(string, null)
        correlation_filter = optional(object({
          content_type        = optional(string, null)
          correlation_id      = optional(string, null)
          label               = optional(string, null)
          message_id          = optional(string, null)
          reply_to            = optional(string, null)
          reply_to_session_id = optional(string, null)
          session_id          = optional(string, null)
          to                  = optional(string, null)
          properties          = optional(map(string), {})
        }), null)
      })), {})
    })), {})
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Map of Service Bus topics to create. The map key is the topic name. Each topic can optionally contain a subscriptions map.

- `max_size_in_megabytes` - Max topic size in MB. Defaults to `1024`.
- `max_message_size_in_kilobytes` - Max message size in KB (Premium only). Defaults to `null`.
- `default_message_ttl` - Message TTL as ISO 8601. `null` = no expiry.
- `requires_duplicate_detection` - Enable duplicate detection. Defaults to `false`.
- `duplicate_detection_history_time_window` - Duplicate detection window. Defaults to `"PT10M"`.
- `support_ordering` - Enable message ordering support. Defaults to `false`.
- `auto_delete_on_idle` - ISO 8601 idle interval before auto-deletion. `null` = disabled.
- `subscriptions` - (Optional) Map of subscriptions. Key is the subscription name.
  - `max_delivery_count` - Max delivery attempts before dead-lettering. Defaults to `10`.
  - `lock_duration` - Lock duration as ISO 8601. Defaults to `"PT1M"`.
  - `requires_session` - Require sessions. Defaults to `false`.
  - `default_message_ttl` - Message TTL as ISO 8601. `null` = no expiry.
  - `dead_lettering_on_message_expiration` - Dead-letter expired messages. Defaults to `true`.
  - `dead_lettering_on_filter_evaluation_error` - Dead-letter on filter failure. Defaults to `true`.
  - `batched_operations_enabled` - Enable batched operations. Defaults to `true`.
  - `forward_to` - Queue or topic name to forward messages to. `null` = disabled.
  - `forward_dead_lettered_messages_to` - Queue or topic to forward dead-lettered messages to. `null` = disabled.
  - `auto_delete_on_idle` - ISO 8601 idle interval before auto-deletion. `null` = disabled.
  - `rules` - (Optional) Map of subscription rules. Key is the rule name.
    - `filter_type` - (Required) Type of filter: `"SqlFilter"` or `"CorrelationFilter"`.
    - `sql_filter` - SQL expression. Required when `filter_type` is `"SqlFilter"`.
    - `action` - (Optional) SQL action expression to run on matched messages.
    - `correlation_filter` - (Optional) Structured filter. Required when `filter_type` is `"CorrelationFilter"`. At least one field must be set.
      - `content_type` - Content type of the message.
      - `correlation_id` - Correlation identifier.
      - `label` - Application-specific label.
      - `message_id` - Message identifier.
      - `reply_to` - Reply-to address.
      - `reply_to_session_id` - Reply-to session identifier.
      - `session_id` - Session identifier.
      - `to` - Send-to address.
      - `properties` - Map of user-defined properties for matching.
DESCRIPTION
}

variable "private_endpoints" {
  type = map(object({
    subnet_id            = string
    private_dns_zone_ids = optional(list(string), [])
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Map of private endpoints to create for the Service Bus namespace. Requires Premium SKU.

- Key: logical name used as the private endpoint resource name. Must be 1–80 characters, alphanumeric, hyphens, or underscores, and must start with a letter.
- `subnet_id` - Resource ID of the subnet to place the private endpoint in.
- `private_dns_zone_ids` - List of private DNS zone resource IDs to link. Defaults to empty.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Map of Azure RBAC role assignments to create on the Service Bus namespace.

- Key: logical name for the assignment.
- `role_definition_name` - Built-in role name. Common values: "Azure Service Bus Data Owner", "Azure Service Bus Data Sender", "Azure Service Bus Data Receiver".
- `principal_id` - Object ID of the principal (managed identity, service principal, user, or group).

Use this to grant non-Azure workloads access by assigning their Entra ID app registration's object ID with the "Azure Service Bus Data Sender" or "Azure Service Bus Data Receiver" role.
DESCRIPTION
}

variable "queues" {
  type = map(object({
    max_delivery_count                      = optional(number, 10)
    max_size_in_megabytes                   = optional(number, 1024)
    max_message_size_in_kilobytes           = optional(number, null)
    default_message_ttl                     = optional(string, null)
    lock_duration                           = optional(string, "PT1M")
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, "PT10M")
    requires_session                        = optional(bool, false)
    dead_lettering_on_message_expiration    = optional(bool, true)
    batched_operations_enabled              = optional(bool, true)
    auto_delete_on_idle                     = optional(string, null)
    forward_to                              = optional(string, null)
    forward_dead_lettered_messages_to       = optional(string, null)
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Map of Service Bus queues to create. The map key is the queue name.

- `max_delivery_count` - Max delivery attempts before dead-lettering. Defaults to `10`.
- `max_size_in_megabytes` - Max queue size in MB (1024–81920 for Premium). Defaults to `1024`.
- `max_message_size_in_kilobytes` - Max message size in KB (Premium only, up to 102400). Defaults to `null`.
- `default_message_ttl` - Message time-to-live as ISO 8601 (e.g. `"PT1H"`). `null` = no expiry.
- `lock_duration` - Message lock duration as ISO 8601 (max `"PT5M"`). Defaults to `"PT1M"`.
- `requires_duplicate_detection` - Enable duplicate detection. Defaults to `false`.
- `duplicate_detection_history_time_window` - Duplicate detection window as ISO 8601. Defaults to `"PT10M"`.
- `requires_session` - Require sessions. Defaults to `false`.
- `dead_lettering_on_message_expiration` - Dead-letter expired messages. Defaults to `true`.
- `batched_operations_enabled` - Enable batched operations. Defaults to `true`.
- `auto_delete_on_idle` - ISO 8601 idle interval before auto-deletion. `null` = disabled.
- `forward_to` - Queue or topic name to forward messages to. `null` = disabled.
- `forward_dead_lettered_messages_to` - Queue or topic name to forward dead-lettered messages to. `null` = disabled.
DESCRIPTION
}

variable "cmk" {
  type = object({
    key_vault_id              = string
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Customer-managed key (CMK) configuration for namespace encryption. Requires Premium SKU and an identity on the namespace.

- `key_vault_id` - Resource ID of the Key Vault (used to scope the Key Vault Crypto Service Encryption User role assignment).
- `key_vault_key_id` - Full versioned key URI from the Key Vault (e.g. `https://myvault.vault.azure.net/keys/mykey/abc123`).
- `user_assigned_identity_id` - (Optional) Resource ID of the user-assigned identity to use for Key Vault access. If omitted, the system-assigned identity is used. Required when `system_assigned_identity_enabled = false`.
DESCRIPTION
}
