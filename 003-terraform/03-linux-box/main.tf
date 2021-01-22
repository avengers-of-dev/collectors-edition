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
        container_name       = "tfstate-impinfra"
        resource_group_name  = "rg-default-kstjj-001"
        key                  = "codelab.microsoft.tfstate"
    }
    
    required_providers {

        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 2.43"
        }

        http = {
            source  = "hashicorp/http"
            version = "~> 2.0"
        }
    }
}