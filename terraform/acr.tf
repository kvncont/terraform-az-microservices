resource "azurerm_container_registry" "acr" {
  name                          = "acr${var.suffix_resource_name}"
  location                      = azurerm_resource_group.rg_microservices.location
  resource_group_name           = azurerm_resource_group.rg_microservices.name
  sku                           = "Premium"
  public_network_access_enabled = false
  admin_enabled                 = true
  depends_on = [
    azurerm_key_vault.key_vault
  ]

  tags = var.tags
}

resource "azurerm_key_vault_secret" "key_vault_secret_acr_pass" {
  name         = "ACR-ADMIN-PASS"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_private_dns_zone" "pdnsz_acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg_microservices.name
  tags                = var.tags
}

resource "azurerm_private_endpoint" "pe_acr" {
  name                = "pe-${azurerm_container_registry.acr.name}"
  location            = azurerm_resource_group.rg_microservices.location
  resource_group_name = azurerm_resource_group.rg_microservices.name
  subnet_id           = azurerm_subnet.snet_pe.id

  private_service_connection {
    name                           = azurerm_container_registry.acr.name
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.pdnsz_acr.name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_acr.id]
  }

  tags = var.tags
}

# Azure DevOps Service Connection Config
resource "azuredevops_serviceendpoint_dockerregistry" "svc_acr" {
  project_id            = data.azuredevops_project.coders.id
  service_endpoint_name = "${var.prefix_svc_name}_${upper(azurerm_container_registry.acr.name)}"
  docker_registry       = azurerm_container_registry.acr.login_server
  docker_username       = azurerm_container_registry.acr.admin_username
  docker_password       = azurerm_container_registry.acr.admin_password
  registry_type         = "Others"

  depends_on = [
    azurerm_container_registry.acr
  ]
}