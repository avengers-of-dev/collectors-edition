provider "azurerm" {
    features {
        key_vault {
            recover_soft_deleted_key_vaults = false #defaults to true
        }
    }
}

provider "http" {}

terraform {
    backend "azurerm" {
        storage_account_name = "stdefaultkstjj001"
        container_name       = "tfstate"
        resource_group_name  = "rg-default-kstjj-001"
        key                  = "codelab.microsoft.tfstate"
    }
    
    required_providers {
        azurerm = {
            version = "=2.0.0"
        }

        http = {
            version = "~> 1.2"
        }
    }
}