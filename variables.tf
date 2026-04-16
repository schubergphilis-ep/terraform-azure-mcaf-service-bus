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

# Placeholder — will be replaced with full type definition in Task 9
variable "topics" {
  type        = any
  default     = {}
  description = "Map of Service Bus topics to create. Placeholder — full type definition with topic and subscription attributes will be replaced in Task 9."
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

- Key: logical name used in the private endpoint resource name.
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
- `user_assigned_identity_id` - (Optional) Resource ID of the user-assigned identity to use for Key Vault access. If omitted, the system-assigned identity is used.
DESCRIPTION
}
