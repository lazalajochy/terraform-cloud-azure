# provides configuration details for terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}



# provides configuration details for the azure terraform provider

provider "azurerm" {
  features {}
  subscription_id = "147d994b-4b52-4afe-b06f-1465aba9d63e"
}




# provides the resource group to logically contain resources

resource "azurerm_resource_group" "rg" {
  name     = "terraform-cloud-test"
  location = "eastus"
  tags = {
    environment = "cloud-test"
    source      = "terraform"
    owner       = "jochy"
    cloud       = "Yes"
    provider    = "terraform cloud"

  }
}

# Azure container registry

resource "azurerm_container_registry" "acr" {
  name                = "acrjochy"
  resource_group_name = "terraform-cloud-test"
  location            = "eastus"
  sku                 = "Basic"
  admin_enabled       = true
  tags = {
    environment = "cloud-test"
    source      = "terraform"
  }
}