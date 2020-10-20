# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform file for devops infrastructure
# Author: Jan Jambor
# Author URI: https://xwr.ch
# Date: 20.10.2020
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

resource "azurerm_resource_group" "devopsserver" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "devopsserver" {
  name                = "devopsserver-network"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.2.7","10.0.2.6"]
  location            = azurerm_resource_group.devopsserver.location
  resource_group_name = azurerm_resource_group.devopsserver.name
}

resource "azurerm_subnet" "devopsserver" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.devopsserver.name
  virtual_network_name = azurerm_virtual_network.devopsserver.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_key_vault" "devopsserver" {
    name                        = var.keyvault_name
    location                    = azurerm_resource_group.devopsserver.location
    resource_group_name         = azurerm_resource_group.devopsserver.name
    enabled_for_disk_encryption = true
    tenant_id                   = var.tenant_id
    soft_delete_enabled         = false # defaults to false
    purge_protection_enabled    = false # defaults to false
    sku_name = "standard"

    # service principal for cluster
    access_policy {
      tenant_id = var.tenant_id
      object_id = var.client_id
      certificate_permissions = [
        #"backup",
        "create",
        "delete",
        "deleteissuers",
        "get",
        "getissuers",
        #"import",
        "list",
        "listissuers",
        "managecontacts",
        "manageissuers",
        #"purge",
        #"recover",
        #"restore",
        "setissuers",
        "update"
      ]
      key_permissions = [
        #"backup",
        "create",
        "decrypt",
        "delete",
        "encrypt",
        "get",
        #"import",
        "list",
        #"purge",
        #"recover",
        #"restore",
        "sign",
        "unwrapKey",
        "update",
        "verify",
        "wrapKey"
      ]
      secret_permissions = [
        #"backup",
        "delete",
        "get",
        "list",
        #"purge",
        #"recover",
        #"restore",
        "set"
      ]
      storage_permissions = [
        #"backup",
        "delete",
        "deletesas",
        "get",
        "getsas",
        "list",
        "listsas",
        #"purge",
        #"recover",
        "regeneratekey",
        #"restore",
        "set",
        "setsas",
        "update"
      ]
    }

    # permissions for admin user
    access_policy {
      tenant_id = var.tenant_id
      object_id = var.admin_client_id
      certificate_permissions = [
        "backup",
        "create",
        "delete",
        "deleteissuers",
        "get",
        "getissuers",
        "import",
        "list",
        "listissuers",
        "managecontacts",
        "manageissuers",
        "purge",
        "recover",
        "restore",
        "setissuers",
        "update"
      ]
      key_permissions = [
        "backup",
        "create",
        "decrypt",
        "delete",
        "encrypt",
        "get",
        "import",
        "list",
        "purge",
        "recover",
        "restore",
        "sign",
        "unwrapKey",
        "update",
        "verify",
        "wrapKey"
      ]
      secret_permissions = [
        "backup",
        "delete",
        "get",
        "list",
        "purge",
        "recover",
        "restore",
        "set"
      ]
      storage_permissions = [
        "backup",
        "delete",
        "deletesas",
        "get",
        "getsas",
        "list",
        "listsas",
        "purge",
        "recover",
        "regeneratekey",
        "restore",
        "set",
        "setsas",
        "update"
      ]
    }

    network_acls {
      default_action = "Deny"
      bypass         = "AzureServices"
      ip_rules       = ["${chomp(data.http.myip.body)}/32"]
    }

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}

resource "azurerm_storage_account" "devopsserver" {
    name                      = var.storage_name
    resource_group_name       = azurerm_resource_group.devopsserver.name
    location                  = azurerm_resource_group.devopsserver.location
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

resource "azurerm_storage_share" "devopsserver" {
    name                 = var.storage_share_name
    storage_account_name = azurerm_storage_account.devopsserver.name
    quota                = 50
}

resource "azurerm_network_security_group" "devopsserver" {
    name                = "devopsserverNetworkSecurityGroup"
    location            = azurerm_resource_group.devopsserver.location
    resource_group_name = azurerm_resource_group.devopsserver.name

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "22"
        direction                  = "Inbound"
        name                       = "SSH"
        priority                   = 1201
        protocol                   = "Tcp"
        source_address_prefix      = "${chomp(data.http.myip.body)}/32"
        source_port_range          = "*"
    }

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "3389"
        direction                  = "Inbound"
        name                       = "RDP"
        priority                   = 1001
        protocol                   = "Tcp"
        source_address_prefix      = "${chomp(data.http.myip.body)}/32"
        source_port_range          = "*"
    }

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "443"
        direction                  = "Inbound"
        name                       = "HTTPS"
        priority                   = 1101
        protocol                   = "Tcp"
        source_address_prefix      = "${chomp(data.http.myip.body)}/32"
        source_port_range          = "*"
    }

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "80"
        direction                  = "Inbound"
        name                       = "HTTP"
        priority                   = 1111
        protocol                   = "Tcp"
        source_address_prefix      = "${chomp(data.http.myip.body)}/32"
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
# SQL servers on vms
# VM for SQL DevOPS Server
#
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_public_ip" "devops-sql1" {
    name                         = "devops-sql1"
    location                     = azurerm_resource_group.devopsserver.location
    resource_group_name          = azurerm_resource_group.devopsserver.name
    allocation_method            = "Dynamic"

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}
resource "azurerm_network_interface" "devops-sql1-nic" {
  name                = "devops-sql1-nic"
  location            = azurerm_resource_group.devopsserver.location
  resource_group_name = azurerm_resource_group.devopsserver.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devopsserver.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops-sql1.id
  }

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_network_interface_security_group_association" "devops-sql1" {
    network_interface_id      = azurerm_network_interface.devops-sql1-nic.id
    network_security_group_id = azurerm_network_security_group.devopsserver.id
}

resource "azurerm_windows_virtual_machine" "devops-sql1" {
  name                = "devops-sql1"
  resource_group_name = azurerm_resource_group.devopsserver.name
  location            = azurerm_resource_group.devopsserver.location
  size                = "Standard_B4ms"
  admin_username      = var.win_user
  admin_password      = var.win_pass

  network_interface_ids = [
    azurerm_network_interface.devops-sql1-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftsqlserver"
    offer     = "sql2019-ws2019"
    sku       = "standard"
    version   = "latest"
  }

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

#
# TODO
# - login mode (sql & windows) is not set
# - sql user is not set
# terraform import azurerm_virtual_machine_extension.devops-sql1 /subscriptions/d9d8152f-7962-4dc6-a6eb-bcad103bda4a/resourceGroups/rg-devopsserver-kstjj-001/providers/Microsoft.Compute/virtualMachines/devops-sql1/extensions/devops-sql1
resource "azurerm_virtual_machine_extension" "devops-sql1" {
  name                 = "devops-sql1"
  virtual_machine_id   = azurerm_windows_virtual_machine.devops-sql1.id
  # publisher            = "Microsoft.Azure.Extensions"
  # type                 = "CustomScript"
  # type_handler_version = "2.0"
  publisher            = "Microsoft.SqlServer.Management"
  type                 = "SqlIaaSAgent"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "SqlServerLicenseType": "PAYG",
        
        "AutoPatchingSettings": {
          "PatchCategory": "WindowsMandatoryUpdates",
          "Enable": true,
          "DayOfWeek": "Sunday",
          "MaintenanceWindowStartingHour": "2",
          "MaintenanceWindowDuration": "60"
        },
        "KeyVaultCredentialSettings": {
          "Enable": false,
          "CredentialName": ""
        },
        "ServerConfigurationsManagementSettings": {
          "SQLConnectivityUpdateSettings": {
              "ConnectivityType": "Private",
              "Port": "1433",
              "SQLAuthUpdateUserName": "${var.win_user}",
              "SQLAuthUpdatePassword": "${var.win_pass}"
          },
          "SQLWorkloadTypeUpdateSettings": {
              "SQLWorkloadType": "GENERAL"
          },
          "AdditionalFeaturesServerConfigurations": {
              "IsRServicesEnabled": "false"
          } ,
          "protectedSettings": {
              "SQLAuthUpdateUserName": "${var.win_user}",
              "SQLAuthUpdatePassword": "${var.win_pass}"
            }
          }
      }
SETTINGS

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Empty VM for APP DevOPS Server
# 
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_public_ip" "devops-app1" {
    name                         = "devops-app1"
    location                     = azurerm_resource_group.devopsserver.location
    resource_group_name          = azurerm_resource_group.devopsserver.name
    allocation_method            = "Static"

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}

resource "azurerm_network_interface" "devops-app1-nic" {
  name                = "devops-app1-nic"
  location            = azurerm_resource_group.devopsserver.location
  resource_group_name = azurerm_resource_group.devopsserver.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devopsserver.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops-app1.id
  }

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_network_interface_security_group_association" "devops-app1" {
    network_interface_id      = azurerm_network_interface.devops-app1-nic.id
    network_security_group_id = azurerm_network_security_group.devopsserver.id
}

resource "azurerm_windows_virtual_machine" "devops-app1" {
  name                = "devops-app1"
  resource_group_name = azurerm_resource_group.devopsserver.name
  location            = azurerm_resource_group.devopsserver.location
  size                = "Standard_B4ms"
  admin_username      = var.win_user
  admin_password      = var.win_pass

  network_interface_ids = [
    azurerm_network_interface.devops-app1-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment = var.tag_environment
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}
