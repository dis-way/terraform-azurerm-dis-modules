variable "ipv4_cidr_subnet" {
  type        = string
  description = "IPv4 CIDR block for the subnet (e.g. 172.30.1.0/27)"

  validation {
    condition     = can(cidrhost(var.ipv4_cidr_subnet, 0))
    error_message = "ipv4_cidr_subnet must be a valid IPv4 CIDR block."
  }
}

variable "ipv4_cidr_vnet" {
  type        = string
  description = "IPv4 CIDR block for the virtual network (e.g. 172.30.1.0/24)"

  validation {
    condition     = can(cidrhost(var.ipv4_cidr_vnet, 0))
    error_message = "ipv4_cidr_vnet must be a valid IPv4 CIDR block."
  }
}

variable "ipv6_cidr_subnet" {
  type        = string
  description = "IPv6 /64 CIDR block for the subnet"

  validation {
    condition     = can(cidrhost(var.ipv6_cidr_subnet, 0))
    error_message = "ipv6_cidr_subnet must be a valid IPv6 CIDR block."
  }
}

variable "ipv6_cidr_vnet" {
  type        = string
  description = "IPv6 ULA /48 CIDR block for the virtual network"

  validation {
    condition     = can(cidrhost(var.ipv6_cidr_vnet, 0))
    error_message = "ipv6_cidr_vnet must be a valid IPv6 CIDR block."
  }
}

variable "location" {
  type        = string
  description = "Azure region"

  validation {
    condition     = length(var.location) > 0
    error_message = "location must not be empty."
  }
}

variable "name" {
  type        = string
  description = "Name used for all resources in this node (e.g. ts-exit-test)"

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to deploy into"

  validation {
    condition     = length(var.resource_group) > 0
    error_message = "resource_group must not be empty."
  }
}

variable "service_endpoints" {
  type        = list(string)
  description = "List of service endpoints to enable on the subnet (e.g. Microsoft.Sql, Microsoft.Storage)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources, merged with submodule tag"
  default     = {}
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.tailscale_auth_key) > 0
    error_message = "tailscale_auth_key must not be empty."
  }
}

variable "ansible_pull_gh_app_private_key" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.ansible_pull_gh_app_private_key) > 0
    error_message = "ansible_pull_gh_app_private_key must not be empty."
  }
}
