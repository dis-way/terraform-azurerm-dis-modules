variable "enable_grafana_operator" {
  type        = bool
  description = "Toggle deployment of grafana operator in cluster. If deployed grafana_endpoint must be defined"
  default     = true
}

variable "grafana_dashboard_release_branch" {
  type        = string
  default     = "release"
  description = "Grafana dashboard release branch"
  validation {
    condition     = can(regex("^[-A-Za-z0-9_/\\.]+$", var.grafana_dashboard_release_branch))
    error_message = "grafana_dashboard_release_branch must be a valid Git branch (alphanumeric, '-', '_', '/', or '.')."
  }
}

variable "grafana_endpoint" {
  type        = string
  description = "URL endpoint for Grafana dashboard access"
  default     = ""
  validation {
    condition     = var.enable_grafana_operator == false || (var.enable_grafana_operator == true && length(var.grafana_endpoint) > 0)
    error_message = "You must provide a value for grafana_endpoint when enable_grafana_operator is true."
  }
}

variable "grafana_redirect_dns" {
  type        = string
  description = "External DNS name used for Grafana redirect; must resolve to the AKS cluster where the Grafana operator is deployed."
  default     = ""
  validation {
    condition     = var.enable_grafana_operator == false || (var.enable_grafana_operator == true && length(var.grafana_redirect_dns) > 0)
    error_message = "You must provide a value for grafana_redirect_dns when enable_grafana_operator is true and the DNS must point to the target cluster."
  }
}

variable "token_grafana_operator" {
  type        = string
  sensitive   = true
  description = "Authentication token for Grafana operator to manage Grafana resources"
  default     = ""
}
