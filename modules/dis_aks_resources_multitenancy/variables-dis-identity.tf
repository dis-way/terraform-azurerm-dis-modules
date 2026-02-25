variable "azurerm_dis_identity_resource_group_id" {
  type        = string
  description = "The resource group ID where the User Assigned Managed Identity managed by dis-identity-operator will be created."
}

variable "azurerm_kubernetes_cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL of the AKS cluster."
}

variable "dis_identity_target_namespace" {
  type        = string
  description = "Namespace where the dis-identity operator deployment will be created."
  default     = "flux-system"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.dis_identity_target_namespace))
    error_message = "dis_identity_target_namespace must be a valid Kubernetes namespace (DNS-1123 label)."
  }
}
