# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform file for managed k8s infrastructure
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

resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "k8s" {
  name                = "k8s-network"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.2.7","10.0.2.6"]
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_subnet" "k8s" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8s.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_key_vault" "k82" {
    name                        = var.keyvault_name
    location                    = azurerm_resource_group.k8s.location
    resource_group_name         = azurerm_resource_group.k8s.name
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

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Storage & Storage Share - admin parts
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_storage_account" "k8s" {
    name                      = var.storage_name
    resource_group_name       = azurerm_resource_group.k8s.name
    location                  = azurerm_resource_group.k8s.location
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

resource "azurerm_storage_share" "k8s" {
    name                 = var.storage_share_name
    storage_account_name = azurerm_storage_account.k8s.name
    quota                = 50
}

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Storage & Storage Share - database parts
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_storage_account" "k8s-database" {
    name                      = "stk8sdatabasekstjj001"
    resource_group_name       = azurerm_resource_group.k8s.name
    location                  = azurerm_resource_group.k8s.location
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

resource "azurerm_storage_share" "k8s-database" {
    name                 = "shstk8sdatabasekstjj001"
    storage_account_name = azurerm_storage_account.k8s-database.name
    quota                = 50
}

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Network Security
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_network_security_group" "k8s" {
    name                = "k8sNetworkSecurityGroup"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "20.71.51.55"
        destination_port_range     = "443"
        direction                  = "Inbound"
        name                       = "HTTPS"
        priority                   = 1101
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
    }

    security_rule {
        access                     = "Allow"
        destination_address_prefix = "20.71.51.55"
        destination_port_range     = "80"
        direction                  = "Inbound"
        name                       = "HTTP"
        priority                   = 1111
        protocol                   = "Tcp"
        source_address_prefix      = "*"
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
# k8s cluster
# # # # # # # # # # # # # # # # # # # # # # # # # #

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix
    kubernetes_version  = var.kubernetes_version

    linux_profile {
        admin_username = "ubuntu"
        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_B4ms"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
      
      kube_dashboard {
        enabled       = false
      }
      
      oms_agent {
        enabled       = false
      }
    }

    tags = {
        Environment = var.tag_environment
        Owner = var.tag_owner
        ApplicationName = var.tag_application_name
        CostCenter = var.tag_costcenter
        DR = var.tag_dr
    }
}