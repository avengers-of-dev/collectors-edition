# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform variables file for azure devops server infrastructure
# Author: Jan Jambor
# Author URI: https://xwr.ch
# Date: 16.11.2020
#
# # # # # # # # # # # # # # # # # # # # # # # # # #

# tenant & client id's input via cli var
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
# used to allow admin user to see secrets in vault
# az ad user show --upn-or-object-id jan.jambor@xwr.ch | jq -r .objectId
variable "admin_client_id" {}

# general settings
variable location {
    default = "West Europe"
}

variable resource_group_name {
    default = "rg-devopsserver-kstjj-001"
}

variable keyvault_name {
    default = "kv-devopsserver-vault"
}

# azdo related variables
variable "win_user" {}
variable "win_pass" {}

# tags for all generated ressources
variable "tag_environment" {
  default     = "test"
}
variable "tag_owner" {
  default     = "jan.jambor@xwr.ch"
}
variable "tag_application_name" {
  default     = "azdo"
}
variable "tag_costcenter" {
  default     = "jj"
}
variable "tag_dr" {
  default     = "essential"
}