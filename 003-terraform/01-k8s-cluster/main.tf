provider "azurerm" {
    #version = "~>1.5"
    version = "=2.0.0"
    features {
        key_vault {
            recover_soft_deleted_key_vaults = false #defaults to true
        }
    }
}

provider "http" {
    version = "~> 1.2"
}

terraform {
    backend "azurerm" {
        storage_account_name = "stdefaultkstjj001"
        container_name       = "tfstate"
        resource_group_name  = "rg-default-kstjj-001"
        key                  = "codelab.microsoft.tfstate"
    }
}