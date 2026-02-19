variable "azurerm_dis_identity_resource_group_id" {
  type        = string
  description = "The resource group ID where the User Assigned Managed Identity managed by dis-identity-operator will be created."
  default     = ""
  validation {
    condition     = var.enable_dis_identity_operator == false || (var.enable_dis_identity_operator == true && length(var.azurerm_dis_identity_resource_group_id) > 0)
    error_message = "You must provide a value for azurerm_dis_identity_resource_group_id when enable_dis_identity_operator is true."
  }
}

variable "azurerm_kubernetes_cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL of the AKS cluster."
  default     = ""
  validation {
    condition     = var.enable_dis_identity_operator == false || (var.enable_dis_identity_operator == true && length(var.azurerm_kubernetes_cluster_oidc_issuer_url) > 0)
    error_message = "You must provide a value for azurerm_kubernetes_cluster_oidc_issuer_url when enable_dis_identity_operator is true."
  }
}

variable "enable_dis_identity_operator" {
  type        = bool
  default     = false
  description = "Enable the dis-identity-operator to manage User Assigned Managed Identities in the cluster."
}
