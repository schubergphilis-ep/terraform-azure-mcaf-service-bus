variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "servicebus_private_dns_zone_id" {
  type = string
}

variable "sender_principal_id" {
  type        = string
  description = "Object ID of a principal (service principal or managed identity) to grant Data Sender access."
}
