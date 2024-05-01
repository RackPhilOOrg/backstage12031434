resource "azurerm_resource_group" "compute" {
  name     = var.computeResourceGroupName
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "network-rg" {
  name     = var.networkResourceGroupName
  location = var.location
  tags     = local.common_tags
}
