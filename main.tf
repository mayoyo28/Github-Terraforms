terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.32.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name = "TerraformDemo"
    storage_account_name = "terraform2811"
    container_name       = "tfstatefile"
    key                  = "stage.terraform.tfstate"
    }
}

resource "azurerm_resource_group" "arg" {
  name     = "TerraformStageRG"
  location = "East US"
}

resource "azurerm_virtual_network" "avn" {
  name                = "demo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_subnet" "as" {
  name                 = "demo-internal"
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.avn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ani" {
  name                = "demo-nic"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.as.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  
  }
}

resource "azurerm_windows_virtual_machine" "awvm" {
  name                = "stage-machine"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  size                = "Standard_F2"
  admin_username      = ${{secrets.AZURE_VM_USERNAME}}
  admin_password      = ${{secrets.AZURE_VM_PASSWORD}}
  network_interface_ids = [
    azurerm_network_interface.ani.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "stage_dev"
  }
}