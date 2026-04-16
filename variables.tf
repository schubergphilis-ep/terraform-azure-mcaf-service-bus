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

# Placeholder — will be replaced with full type definition in Task 9
variable "topics" {
  type    = any
  default = {}
}
