variable "prefix" {
  description = "A prefix to be used for naming resources."
  type        = string
}

variable "environment" {
  description = "The environment for which the dis-messaging resources are created. The module passes it to the operator as DISMSG_ENV."
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

variable "kubernetes_cluster_id" {
  description = "Resource ID of the AKS cluster. The module creates the Flux configuration of dis-messaging-operator on this cluster."
  type        = string
  validation {
    condition     = length(trimspace(var.kubernetes_cluster_id)) > 0
    error_message = "You must provide a value for kubernetes_cluster_id."
  }
}

variable "tenant_id" {
  description = "ID of the Entra ID tenant of the Azure Service Bus namespace (DISMSG_AZURE_TENANT_ID of the operator)."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a UUID."
  }
}

variable "flux_release_tag" {
  description = "Tag of the dis-messaging OCI artifact that Flux reconciles, for example at_ring1. Use the ring tag of the other DIS operators of the cluster."
  type        = string
  validation {
    condition     = length(trimspace(var.flux_release_tag)) > 0
    error_message = "You must provide a value for flux_release_tag."
  }
}
