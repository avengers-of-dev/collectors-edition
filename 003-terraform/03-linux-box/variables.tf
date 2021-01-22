# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform variables file for api load tool infra
# Author: Jan Jambor
# Author URI: https://xwr.ch
# Date: 19.01.2021
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
    default = "rg-impinfra-kstjj-001"
}

variable keyvault_name {
    default = "kv-impinfra-vault"
}

variable storage_name {
    # only letters and numbers!
    default = "stimpinfrakstjj001"
}
variable storage_share_name {
    # only letters and numbers!
    default = "shstimpinfrakstjj001"
}

# impinfra related variables
#variable "user" {}
#variable "key" {}

# tags for all generated ressources
variable "tag_environment" {
  default     = "test"
}
variable "tag_owner" {
  default     = "jan.jambor@xwr.ch"
}
variable "tag_application_name" {
  default     = "impinfra"
}
variable "tag_costcenter" {
  default     = "jj"
}
variable "tag_dr" {
  default     = "essential"
}