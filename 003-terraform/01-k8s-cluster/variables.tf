# # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Content: terraform variables file for k8s cluster
# Author: Jan Jambor
# Author URI: https://xwr.ch
# Date: 23.03.2020
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
    default = "rg-k8s-kstjj-001"
}

variable storage_name {
    # only letters and numbers!
    default = "stk8skstjj001"
}
variable storage_share_name {
    # only letters and numbers!
    default = "shstk8skstjj001"
}

# k8s variables
variable "kubernetes_version" {
  description = "Version of Kubernetes to install"
  default     = "1.19.3"
}
variable "agent_count" {
    default = 2
}
variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}
variable "dns_prefix" {
    default = "k8s"
}
variable cluster_name {
    default = "aks-k8s"
}
variable keyvault_name {
    default = "kv-k8s-vault"
}

# tags for all generated ressources
variable "tag_environment" {
  default     = "test"
}
variable "tag_owner" {
  default     = "jan.jambor@xwr.ch"
}
variable "tag_application_name" {
  default     = "k8s"
}
variable "tag_costcenter" {
  default     = "jj"
}
variable "tag_dr" {
  default     = "essential"
}