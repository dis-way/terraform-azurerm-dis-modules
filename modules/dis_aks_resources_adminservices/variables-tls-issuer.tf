variable "enable_cert_manager_tls_issuer" {
  type        = bool
  default     = true
  description = "Enable cert-manager issuer for TLS certificates"
}

variable "tls_cert_manager_workload_identity_client_id" {
  type        = string
  description = "Client id for cert-manager workload identity"
  default     = ""
  validation {
    condition     = var.enable_cert_manager_tls_issuer == false || (var.enable_cert_manager_tls_issuer == true && length(var.tls_cert_manager_workload_identity_client_id) > 0)
    error_message = "You must provide a value for tls_cert_manager_workload_identity_client_id when enable_cert_manager_tls_issuer is true."
  }
}

variable "tls_cert_manager_zone_name" {
  type        = string
  description = "Azure DNS zone name for TLS certificates"
  default     = ""
  validation {
    condition     = var.enable_cert_manager_tls_issuer == false || (var.enable_cert_manager_tls_issuer == true && length(var.tls_cert_manager_zone_name) > 0)
    error_message = "You must provide a value for tls_cert_manager_zone_name when enable_cert_manager_tls_issuer is true."
  }
}

variable "tls_cert_manager_zone_rg_name" {
  type        = string
  description = "Azure DNS zone resource group name for TLS certificates"
  default     = ""
  validation {
    condition     = var.enable_cert_manager_tls_issuer == false || (var.enable_cert_manager_tls_issuer == true && length(var.tls_cert_manager_zone_rg_name) > 0)
    error_message = "You must provide a value for tls_cert_manager_zone_rg_name when enable_cert_manager_tls_issuer is true."
  }
}
