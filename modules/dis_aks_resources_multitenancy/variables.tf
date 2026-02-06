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

variable "aks_vnet_ipv4_cidr" {
  type        = string
  description = "AKS VNet IPv4 CIDR"
}

variable "aks_vnet_ipv6_cidr" {
  type        = string
  description = "AKS VNet IPv6 CIDR"
}

variable "aks_node_resource_group" {
  type        = string
  description = "AKS node resource group"
}

variable "aks_public_ipv4_address" {
  type = string
  description = "The public IPv4 address of the AKS cluster"
}

variable "aks_public_ipv6_address" {
  type = string
  description = "The public IPv6 address of the AKS cluster"
}

variable "default_gateway_hostname" {
  type = string
  description = "The default gateway hostname of the AKS cluster. This will be the Hostname in the default gateway https://gateway-api.sigs.k8s.io/reference/spec/#hostname"
}
