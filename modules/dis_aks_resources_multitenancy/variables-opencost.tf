variable "enable_opencost" {
  type        = bool
  default     = false
  description = "Enable opencost"
}

variable "opencost_tenant_id" {
  type        = string
  sensitive   = true
  description = "Tenant id where the azure monitoring workspace is deployed"
  default     = ""
  validation {
    condition     = var.enable_opencost ? length(var.opencost_tenant_id) > 0 : true
    error_message = "opencost_tenant_id must be provided when enable_opencost is true."
  }
}

variable "opencost_azure_monitoring_workspace_id" {
  type        = string
  description = "Azure id of the monitoring workspace to read from"
  default     = ""
  validation {
    condition     = var.enable_opencost ? length(var.opencost_azure_monitoring_workspace_id) > 0 : true
    error_message = "opencost_azure_monitoring_workspace_id must be provided when enable_opencost is true."
  }
}

variable "opencost_prometheus_endpoint" {
  type        = string
  description = "URL of the prometheus endpint that opencost queries"
  default     = ""
  validation {
    condition     = var.enable_opencost ? length(var.opencost_prometheus_endpoint) > 0 : true
    error_message = "opencost_prometheus_endpoint must be provided when enable_opencost is true."
  }
}
