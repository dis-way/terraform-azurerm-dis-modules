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

variable "traefik_internal_enabled" {
  type        = bool
  description = "Create an internal (private) Load Balancer Service for the Traefik https-internal entrypoint"
  default     = false
}

variable "traefik_internal_subnet_name" {
  type        = string
  description = "Subnet name for the internal Load Balancer frontend (must be in the AKS VNet)"
  default     = ""
}

variable "traefik_internal_ipv4" {
  type        = string
  description = "Static private IPv4 address for the internal Load Balancer"
  default     = ""
}

variable "traefik_internal_ipv6" {
  type        = string
  description = "Static private IPv6 address for the internal Load Balancer"
  default     = ""
}
