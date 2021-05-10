# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform file for api load tool infra
# Author: Jan Jambor
# Author URI: https://xwr.ch
# Date: 19.01.2021
#
# TODO
# - add users
#
# # # # # # # # # # # # # # # # # # # # # # # # # #

# get the local ip address for ip_rules
# source: https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Basic ressources
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_resource_group" "impinfra" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "impinfra" {
  name                = "impinfra-network"
  address_space       = ["10.0.0.0/16"]
  #dns_servers         = ["10.0.2.7","10.0.2.6"]
  location            = azurerm_resource_group.impinfra.location
  resource_group_name = azurerm_resource_group.impinfra.name
}

resource "azurerm_subnet" "impinfra" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.impinfra.name
  virtual_network_name = azurerm_virtual_network.impinfra.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "impinfra" {
    name                      = var.storage_name
    resource_group_name       = azurerm_resource_group.impinfra.name
    location                  = azurerm_resource_group.impinfra.location
    account_kind              = "Storage" # defaults "StorageV2"
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    enable_https_traffic_only = "true"

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}

resource "azurerm_storage_share" "impinfra" {
    name                 = var.storage_share_name
    storage_account_name = azurerm_storage_account.impinfra.name
    quota                = 50
}

resource "azurerm_network_security_group" "impinfra" {
    name                = "impinfraNetworkSecurityGroup"
    location            = azurerm_resource_group.impinfra.location
    resource_group_name = azurerm_resource_group.impinfra.name

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "22"
        direction                  = "Inbound"
        name                       = "SSH"
        priority                   = 1201
        protocol                   = "TCP"
        source_address_prefixes    = ["${chomp(data.http.myip.body)}/32", "More IP Addresses"]
        source_port_range          = "*"

    }

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "5001-5099"
        direction                  = "Inbound"
        name                       = "RIB"
        priority                   = 1101
        protocol                   = "TCP"
        source_address_prefixes    = ["${chomp(data.http.myip.body)}/32", "More IP Addresses"]
        source_port_range          = "*"
    }

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}

# # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# VM for RIB API Tool CLient
#
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_public_ip" "impinfra-cli1" {
    name                         = "impinfra-cli1"
    location                     = azurerm_resource_group.impinfra.location
    resource_group_name          = azurerm_resource_group.impinfra.name
    allocation_method            = "Dynamic"

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}
resource "azurerm_network_interface" "impinfra-cli1-nic" {
  name                = "impinfra-cli1-nic"
  location            = azurerm_resource_group.impinfra.location
  resource_group_name = azurerm_resource_group.impinfra.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.impinfra.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.impinfra-cli1.id
  }

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_network_interface_security_group_association" "impinfra-cli1" {
    network_interface_id      = azurerm_network_interface.impinfra-cli1-nic.id
    network_security_group_id = azurerm_network_security_group.impinfra.id
}

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "impinfra-cli1"
    location              = azurerm_resource_group.impinfra.location
    resource_group_name   = azurerm_resource_group.impinfra.name
    network_interface_ids = [azurerm_network_interface.impinfra-cli1-nic.id]
    size                  = "Standard_B4ms" # Size of the VM

    os_disk {
        name              = "myOsDisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "impinfra-cli1"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    # boot_diagnostics {
    #     storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    # }

    tags = {
      Environment = var.tag_environment
      Owner = var.tag_owner
      ApplicationName = var.tag_application_name
      CostCenter = var.tag_costcenter
      DR = var.tag_dr
    }
}
