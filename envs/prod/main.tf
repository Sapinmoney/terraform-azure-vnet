resource "azurerm_resource_group" "prod" {
  name     = "rg-prod-westus"
  location = "westus"
}

module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "prod-vnet"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  subnet_prefix       = "10.1.2.0/24"
  tags = {
    environment = "prod"
    owner       = "sapin"
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "prod" {
  name                     = "prodstorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.prod.name
  location                 = azurerm_resource_group.prod.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_network_interface" "prod" {
  name                = "prod-nic"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "prod" {
  name                = "prod-vm"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  size                = "Standard_B1s"   # Free tier eligible
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.prod.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

