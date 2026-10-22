variable "enable_flux_webhook_receiver" {
  type        = bool
  default     = false
  description = "Enable on-demand Flux reconcile through the DIS edge by deploying the webhook receiver and dedicated Traefik listener."

  # Invalid edge CIDRs can make AKS deny traffic to the entire shared public IP.
  validation {
    condition = var.enable_flux_webhook_receiver == false || try(
      !strcontains(var.lb_source_range_dis_edge, ":") && cidrsubnet(var.lb_source_range_dis_edge, 0, 0) == var.lb_source_range_dis_edge,
      false
    )
    error_message = "enable_flux_webhook_receiver needs lb_source_range_dis_edge to be an IPv4 CIDR in canonical form: the network address with no host bits set, for example 192.0.2.0/28."
  }

  validation {
    condition     = var.enable_flux_webhook_receiver == false || try(tonumber(split("/", var.lb_source_range_dis_edge)[1]) > 0, true)
    error_message = "enable_flux_webhook_receiver does not accept an unrestricted lb_source_range_dis_edge such as 0.0.0.0/0. Port 9443 must admit only the dis-edge outbound IPv4 range."
  }

  validation {
    condition     = var.enable_flux_webhook_receiver == false || try(!startswith(var.lb_source_range_dis_edge, "127."), true)
    error_message = "enable_flux_webhook_receiver needs lb_source_range_dis_edge set to the dis-edge outbound IPv4 range. A loopback range, such as the default 127.0.0.1/32, grants no source."
  }

  validation {
    condition = var.enable_flux_webhook_receiver == false || try(
      strcontains(var.lb_source_range_dis_edge_ipv6, ":") && cidrsubnet(var.lb_source_range_dis_edge_ipv6, 0, 0) == var.lb_source_range_dis_edge_ipv6,
      false
    )
    error_message = "enable_flux_webhook_receiver needs lb_source_range_dis_edge_ipv6 to be an IPv6 CIDR in canonical form: the network address with no host bits set, in lowercase with zeros compressed, for example 2001:db8::/124."
  }

  validation {
    condition     = var.enable_flux_webhook_receiver == false || try(tonumber(split("/", var.lb_source_range_dis_edge_ipv6)[1]) > 0, true)
    error_message = "enable_flux_webhook_receiver does not accept an unrestricted lb_source_range_dis_edge_ipv6 such as ::/0. Port 9443 must admit only the dis-edge outbound IPv6 range."
  }

  validation {
    condition     = var.enable_flux_webhook_receiver == false || var.lb_source_range_dis_edge_ipv6 != "::1/128"
    error_message = "enable_flux_webhook_receiver needs lb_source_range_dis_edge_ipv6 set to the dis-edge outbound IPv6 range. The loopback default ::1/128 grants no source."
  }

  # ARM turns an empty substitute into null, and Flux then rejects the Kustomization.
  validation {
    condition     = var.enable_flux_webhook_receiver == false || try(length(trimspace(var.default_gateway_hostname)) > 0, false)
    error_message = "enable_flux_webhook_receiver needs a non-empty default_gateway_hostname. The webhook host name is flux-webhook.<default_gateway_hostname>."
  }
}
