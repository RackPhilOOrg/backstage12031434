resource "azurerm_resource_group" "compute" {
  name     = var.computeResourceGroupName
  location = var.location
}

resource "azurerm_resource_group" "network-rg" {
  name     = var.networkResourceGroupName
  location = var.location
}