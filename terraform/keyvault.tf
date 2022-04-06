resource "azurerm_key_vault" "key_vault_microservices" {
  name                        = "kv-microservices"
  location                    = azurerm_resource_group.rg_microservices.location
  resource_group_name         = azurerm_resource_group.rg_microservices.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Delete"
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Purge"
    ]

    storage_permissions = [
      "Get",
      "Set",
      "List",
      "Delete"
    ]
  }
}

resource "azurerm_private_dns_zone" "pdnsz_key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_microservices.name
}

resource "azurerm_private_endpoint" "pe_key_vault" {
  name                = "pe-${azurerm_key_vault.key_vault_microservices.name}"
  location            = azurerm_resource_group.rg_microservices.location
  resource_group_name = azurerm_resource_group.rg_microservices.name
  subnet_id           = azurerm_subnet.snet_pe.id

  private_service_connection {
    name                           = azurerm_key_vault.key_vault_microservices.name
    private_connection_resource_id = azurerm_key_vault.key_vault_microservices.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.pdnsz_key_vault.name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_key_vault.id]
  }
}
