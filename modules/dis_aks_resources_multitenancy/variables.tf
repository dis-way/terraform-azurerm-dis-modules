variable "subscription_id" {
  type        = string
  description = "Subscription id where aks cluster and other resources are deployed"
}

variable "azurerm_kubernetes_cluster_id" {
  type        = string
  description = "AKS cluster resource id"
}

variable "flux_release_tag" {
  type        = string
  description = "OCI image that Flux should watch and reconcile"
}
