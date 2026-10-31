resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  sku_tier                = var.sku_tier
  tags                    = local.common_tags
  private_cluster_enabled = var.private_cluster
  node_provisioning_profile {
    mode = "Manual"
  }
  default_node_pool {
    name                 = var.system_node_pool.name
    vm_size              = var.system_node_pool.vm_size
    auto_scaling_enabled = true
    min_count            = var.system_node_pool.min_nodes
    max_count            = var.system_node_pool.max_nodes
    vnet_subnet_id       = azurerm_subnet.system.id
  }
  identity { type = "SystemAssigned" }
}
