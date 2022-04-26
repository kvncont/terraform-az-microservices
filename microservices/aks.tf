resource "azurerm_private_dns_zone" "pdnsz_aks" {
  name                = "privatelink.eastus2.azmk8s.io"
  resource_group_name = azurerm_resource_group.rg_microservices.name
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = "aks-${var.suffix_resource_name}"
  location                          = azurerm_resource_group.rg_microservices.location
  resource_group_name               = azurerm_resource_group.rg_microservices.name
  sku_tier                          = "Free"
  dns_prefix                        = "aks-${var.suffix_resource_name}"
  private_cluster_enabled           = true
  private_dns_zone_id               = azurerm_private_dns_zone.pdnsz_aks.id
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    managed            = true
  }

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    zones           = ["1", "2", "3"]
    vnet_subnet_id  = data.azurerm_subnet.snet_aks.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

# Azure DevOps Config Service Connection
resource "azuredevops_serviceendpoint_kubernetes" "svc_k8s" {
  for_each = {
    (data.azuredevops_project.coders.name) = data.azuredevops_project.coders.id,
    (data.azuredevops_project.iac.name)    = data.azuredevops_project.iac.id
  }
  project_id            = each.value
  service_endpoint_name = "${var.prefix_svc_name}_${upper(replace(azurerm_kubernetes_cluster.aks.name, "-", ""))}"
  apiserver_url         = "https://${azurerm_kubernetes_cluster.aks.private_fqdn}"
  authorization_type    = "Kubeconfig"

  kubeconfig {
    kube_config = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  }

  lifecycle {
    ignore_changes = [
      kubeconfig # Comment this line if the cluster needs to be recreated
    ]
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
