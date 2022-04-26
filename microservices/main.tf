terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Azure DevOps
data "azuredevops_project" "coders" {
  name = "Coders"
}

data "azuredevops_project" "iac" {
  name = "Infrastructure as Code Azure"
}

# Azure
data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-kvncontmicroservices"
  resource_group_name = "rg-networking"
}

data "azurerm_subnet" "snet_pe" {
  name                 = "snet-pe"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_subnet" "snet_aks" {
  name                 = "snet-aks"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

resource "azurerm_resource_group" "rg_microservices" {
  name     = "rg-${var.suffix_resource_name}"
  location = "eastus2"
  tags     = var.tags
}
