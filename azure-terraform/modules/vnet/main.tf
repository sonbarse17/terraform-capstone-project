resource "azurerm_virtual_network" "this" {
  name = var.vnet_name
  address_space = [var.address_space]
  location = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

resource "azurerm_subnet" "public" {
  name = "public"
  virtual_network_name = azurerm_virtual_network.this.name 
  resource_group_name = var.resource_group_name
  address_prefixes = var.public_subnets
}

resource "azurerm_subnet" "private" {
  name = "private"
  virtual_network_name = azurerm_virtual_network.this.name 
  resource_group_name = var.resource_group_name
  address_prefixes = var.private_subnets
}