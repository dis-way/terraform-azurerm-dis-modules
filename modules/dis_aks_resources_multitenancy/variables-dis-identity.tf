variable "azurerm_dis_identity_resource_group_id" {
  type        = string
  description = "The resource group ID where the User Assigned Managed Identity managed by dis-identity-operator will be created."
}

variable "azurerm_kubernetes_cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL of the AKS cluster."
}

variable "dis_identity_target_tenant_id" {
  type        = string
  description = "Tenant ID where dis-identity ApplicationIdentity will be created"
  sensitive   = true
}
