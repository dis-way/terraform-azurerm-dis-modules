variable "prefix" {
  description = "A prefix to be used for naming resources."
  type        = string
}

variable "environment" {
  description = "The environment for which the dis-messaging resources are created."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "norwayeast"
}

variable "resource_group_name" {
  description = "Name of the DIS resource group of the cluster. The ASO custom role and its role-assignment delegation are scoped to this group, so the namespace must live here."
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster, used by the federated credential of the operator identity."
  type        = string
  validation {
    condition     = length(trimspace(var.oidc_issuer_url)) > 0
    error_message = "You must provide a value for oidc_issuer_url."
  }
}

variable "sku" {
  description = "Tier of the Azure Service Bus namespace. Premium adds messaging units, autoscaling and the trusted-services firewall bypass."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.sku)
    error_message = "sku must be Standard or Premium."
  }
}

variable "allowed_ipv4_prefixes" {
  description = "IPv4 addresses or CIDR prefixes allowed through the namespace firewall, e.g. the AKS egress prefix and the VPN exit node. At least one is required: Azure does not enforce the Deny default action when the rule list is empty. Service Bus IP rules are IPv4 only."
  type        = list(string)
  validation {
    condition     = length(var.allowed_ipv4_prefixes) > 0 && alltrue([for p in var.allowed_ipv4_prefixes : can(cidrnetmask(strcontains(p, "/") ? p : "${p}/32"))])
    error_message = "allowed_ipv4_prefixes must hold at least one IPv4 address or CIDR prefix, e.g. 203.0.113.0/28."
  }
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace that receives the namespace diagnostic logs."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources created."
  type        = map(string)
  default     = {}
}

variable "namespace_name" {
  description = "Optional override for the namespace name. Defaults to <prefix>-<environment>-messaging."
  type        = string
  default     = ""
}

variable "user_assigned_identity_name" {
  description = "Optional override for the user-assigned identity name of dis-messaging-operator."
  type        = string
  default     = ""
}
