terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------
# RESOURCE GROUP
# ---------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-tp-devops"
  location = "France Central"
}

# ---------------------------------------------------
# VIRTUAL NETWORK
# ---------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# ---------------------------------------------------
# SUBNET
# (Fix : le subnet attend que le VNET soit 100% créé)
# ---------------------------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-tp"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# ---------------------------------------------------
# PUBLIC IP
# (Fix : Standard → Static obligatoire OR Basic → Dynamic)
# Ici : Standard + Static (recommandé)
# ---------------------------------------------------
resource "azurerm_public_ip" "pip" {
  name                = "pip-tp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ---------------------------------------------------
# NETWORK INTERFACE
# ---------------------------------------------------
resource "azurerm_network_interface" "nic" {
  name                = "nic-tp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nicConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# ---------------------------------------------------
# LINUX VIRTUAL MACHINE
# ---------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-tp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_password = "Azure12345!!"         # sécuriser plus tard
  disable_password_authentication = false # pour tests

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# ---------------------------------------------------
# OUTPUTS
# ---------------------------------------------------
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
