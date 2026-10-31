output "resource_group_name" { value = azurerm_resource_group.this.name }
output "virtual_network_id" { value = azurerm_virtual_network.this.id }
output "system_subnet_id" { value = azurerm_subnet.system.id }
output "user_subnet_id" { value = azurerm_subnet.user.id }
output "aks_cluster_id" { value = azurerm_kubernetes_cluster.this.id }
output "aks_cluster_name" { value = azurerm_kubernetes_cluster.this.name }
output "user_node_pool_names" { value = [for pool in azurerm_kubernetes_cluster_node_pool.user : pool.name] }
