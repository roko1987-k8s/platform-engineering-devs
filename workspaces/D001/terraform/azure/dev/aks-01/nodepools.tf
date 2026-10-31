locals {
  user_node_pools = concat([var.user_node_pool], var.additional_user_node_pools)
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each              = { for pool in local.user_node_pools : pool.name => pool }
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  mode                  = "User"
  auto_scaling_enabled  = true
  min_count             = each.value.min_nodes
  max_count             = each.value.max_nodes
  node_count            = each.value.default_nodes
  vnet_subnet_id        = azurerm_subnet.user.id
  tags                  = local.common_tags
}
