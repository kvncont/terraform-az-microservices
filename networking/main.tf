terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }

    # azuredevops = {
    #   source  = "microsoft/azuredevops"
    #   version = ">=0.1.0"
    # }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_networking" {
  name     = "rg-networking"
  location = "eastus2"
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg_networking.location
  resource_group_name = azurerm_resource_group.rg_networking.name
  address_space       = ["172.26.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "snet_pe" {
  name                                           = "snet-pe"
  resource_group_name                            = azurerm_resource_group.rg_networking.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["172.26.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "snet_agw" {
  name                 = "snet-agw"
  resource_group_name  = azurerm_resource_group.rg_networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.26.2.0/24"]
}

resource "azurerm_subnet" "snet_aks" {
  name                                           = "snet-aks"
  resource_group_name                            = azurerm_resource_group.rg_networking.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["172.26.3.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "snet_vmms" {
  name                 = "snet-vmms"
  resource_group_name  = azurerm_resource_group.rg_networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.26.4.0/24"]
}
