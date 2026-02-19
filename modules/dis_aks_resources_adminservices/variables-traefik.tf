variable "aks_node_resource_group" {
  type        = string
  description = "AKS node resource group name"
}

variable "aks_vnet_ipv4_cidr" {
  type        = string
  description = "AKS VNet IPv4 CIDR"
}

variable "aks_vnet_ipv6_cidr" {
  type        = string
  description = "AKS VNet IPv6 CIDR"
}

variable "pip4_ip_address" {
  type        = string
  description = "AKS ipv4 public ip"
}

variable "pip6_ip_address" {
  type        = string
  description = "AKS ipv6 public ip"
}
