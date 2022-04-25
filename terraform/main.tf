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

resource "azurerm_resource_group" "rg_microservices" {
  name     = "rg-${var.suffix_resource_name}"
  location = "eastus2"
  tags     = var.tags
}
