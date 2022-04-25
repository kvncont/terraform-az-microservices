resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg_microservices.location
  resource_group_name = azurerm_resource_group.rg_microservices.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic_vm" {
  name                = "nic-${var.suffix_resource_name}"
  location            = azurerm_resource_group.rg_microservices.location
  resource_group_name = azurerm_resource_group.rg_microservices.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_vmms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.suffix_resource_name}"
  location                        = azurerm_resource_group.rg_microservices.location
  resource_group_name             = azurerm_resource_group.rg_microservices.name
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = var.vm_admin_passwd
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic_vm.id,
  ]

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = var.tags
}

data "local_file" "cloud_init" {
  filename = "${path.module}/config/cloud_init.yaml"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmms" {
  name                            = "vmss-${var.suffix_resource_name}"
  location                        = azurerm_resource_group.rg_microservices.location
  resource_group_name             = azurerm_resource_group.rg_microservices.name
  sku                             = "Standard_B1s"
  instances                       = 1
  admin_username                  = "AzDevOps"
  admin_password                  = var.vm_admin_passwd
  disable_password_authentication = false
  overprovision                   = false
  upgrade_mode                    = "Manual"
  custom_data                     = base64encode(data.local_file.cloud_init.content)

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-azure-devops-${var.suffix_resource_name}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.snet_vmms.id
    }
  }

  boot_diagnostics {}

  lifecycle {
    ignore_changes = [
      instances,
      tags
    ]
  }

  tags = var.tags
}

# Azure DevOps Services
resource "azuredevops_agent_pool" "azdevops_agent_pool" {
  name           = "dev-agent-pool"
  auto_provision = true
  pool_type      = "automation"
}
