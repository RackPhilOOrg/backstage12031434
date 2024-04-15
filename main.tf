terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-terraform12031434"
    storage_account_name = "stoterffst12031434"
    container_name       = "terraform-state12031434"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example..
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
