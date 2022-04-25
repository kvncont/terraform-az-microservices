# ACR
output "acr_login_server" {
  description = "Azure Container Registry login server (URI)"
  value       = azurerm_container_registry.acr.login_server
}

# AKS
output "aks_fqdn" {
  description = "K8s FQDN"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

# Key Vault
output "kv_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.key_vault.vault_uri
}

# Azure DevOps
output "azure_devops_svc_k8s" {
  description = "Service connection name for AKS in Azure DevOps"
  value = {
    for key, project in azuredevops_serviceendpoint_kubernetes.svc_k8s : key => project.service_endpoint_name
  }
}

output "azure_devops_svc_acr" {
  description = "Service connection name for ACR in Azure Devops"
  value       = azuredevops_serviceendpoint_dockerregistry.svc_connection_acr.service_endpoint_name
}
