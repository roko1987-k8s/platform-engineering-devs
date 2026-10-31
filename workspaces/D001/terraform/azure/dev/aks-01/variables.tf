variable "subscription_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "An explicitly authorized Azure subscription ID is required."
  }
}
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "system_subnet_name" { type = string }
variable "user_subnet_name" { type = string }
variable "nsg_name" { type = string }
variable "cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "kubernetes_version" { type = string }
variable "sku_tier" { type = string }
variable "private_cluster" { type = bool }
variable "network_plugin" {
  type     = string
  nullable = true
}
variable "network_plugin_mode" {
  type     = string
  nullable = true
}
variable "network_policy" {
  type     = string
  nullable = true
}
variable "service_cidr" {
  type     = string
  nullable = true
}
variable "dns_service_ip" {
  type     = string
  nullable = true
}
variable "vnet_address_spaces" {
  type     = list(string)
  nullable = true
  validation {
    condition     = var.vnet_address_spaces == null || alltrue([for cidr in var.vnet_address_spaces : can(cidrhost(cidr, 0))])
    error_message = "VNet address spaces must be valid CIDRs."
  }
}
variable "system_subnet_cidr" {
  type     = string
  nullable = true
  validation {
    condition     = var.system_subnet_cidr == null || can(cidrhost(var.system_subnet_cidr, 0))
    error_message = "System subnet must be a valid CIDR."
  }
}
variable "user_subnet_cidr" {
  type     = string
  nullable = true
  validation {
    condition     = var.user_subnet_cidr == null || can(cidrhost(var.user_subnet_cidr, 0))
    error_message = "User subnet must be a valid CIDR."
  }
}
variable "system_node_pool" {
  type = object({ name = string, profile = string, vm_size = string, min_nodes = number, max_nodes = number, default_nodes = number })
  validation {
    condition     = var.system_node_pool.min_nodes <= var.system_node_pool.default_nodes && var.system_node_pool.default_nodes <= var.system_node_pool.max_nodes
    error_message = "System node pool count is outside approved bounds."
  }
}
variable "user_node_pool" {
  type = object({ name = string, profile = string, vm_size = string, min_nodes = number, max_nodes = number, default_nodes = number })
  validation {
    condition     = var.user_node_pool.min_nodes <= var.user_node_pool.default_nodes && var.user_node_pool.default_nodes <= var.user_node_pool.max_nodes
    error_message = "User node pool count is outside approved bounds."
  }
}
variable "additional_user_node_pools" {
  type    = list(object({ name = string, profile = string, vm_size = string, min_nodes = number, max_nodes = number, default_nodes = number }))
  default = []
  validation {
    condition     = length(distinct([for pool in var.additional_user_node_pools : pool.name])) == length(var.additional_user_node_pools) && alltrue([for pool in var.additional_user_node_pools : pool.min_nodes <= pool.default_nodes && pool.default_nodes <= pool.max_nodes])
    error_message = "Additional node pools must have unique names and approved node bounds."
  }
}
variable "tags" { type = map(string) }
