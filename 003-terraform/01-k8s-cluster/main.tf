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
    backend "azurerm" {}
}