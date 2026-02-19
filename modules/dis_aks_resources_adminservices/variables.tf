variable "azurerm_kubernetes_cluster_id" {
  type        = string
  description = "AKS cluster resource id"
}

variable "flux_release_tag" {
  type        = string
  default     = "latest"
  description = "OCI image that Flux should watch and reconcile"
}

variable "subscription_id" {
  type        = string
  description = "Subscription id where aks cluster and other resources are deployed"
}
