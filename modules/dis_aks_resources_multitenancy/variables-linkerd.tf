variable "linkerd_default_inbound_policy" {
  description = "Default inbound policy for Linkerd"
  type        = string
  default     = "deny"
  validation {
    condition     = contains(["all-unauthenticated", "all-authenticated", "cluster-authenticated", "deny"], var.linkerd_default_inbound_policy)
    error_message = "linkerd_default_inbound_policy must be one of: all-unauthenticated, all-authenticated, cluster-authenticated, deny."
  }
}

variable "linkerd_disable_ipv6" {
  description = "Disable IPv6 for Linkerd"
  type        = string
  default     = "false"
  validation {
    condition     = contains(["true", "false"], var.linkerd_disable_ipv6)
    error_message = "linkerd_disable_ipv6 must be either 'true' or 'false'."
  }
}
