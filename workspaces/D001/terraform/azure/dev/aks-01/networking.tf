resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_spaces
  tags                = local.common_tags
}

resource "azurerm_subnet" "system" {
  name                 = var.system_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.system_subnet_cidr]
}

resource "azurerm_subnet" "user" {
  name                 = var.user_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.user_subnet_cidr]
}
