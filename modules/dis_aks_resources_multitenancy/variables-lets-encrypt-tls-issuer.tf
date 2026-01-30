variable "enable_lets_encrypt_tls_issuer" {
  type        = bool
  default     = true
  description = "Enable Let's Encrypt cert-manager issuer for TLS certificates"
}

variable "tls_lets_encrypt_zone_name" {
  type        = string
  description = "Azure DNS zone name for TLS certificates (Let's Encrypt)"
  default     = ""
  validation {
    condition     = var.enable_lets_encrypt_tls_issuer == false || (var.enable_lets_encrypt_tls_issuer == true && length(var.tls_lets_encrypt_zone_name) > 0)
    error_message = "You must provide a value for tls_lets_encrypt_zone_name when enable_lets_encrypt_tls_issuer is true."
  }
}

variable "tls_lets_encrypt_zone_rg_name" {
  type        = string
  description = "Azure DNS zone resource group name for TLS certificates (Let's Encrypt)"
  default     = ""
  validation {
    condition     = var.enable_lets_encrypt_tls_issuer == false || (var.enable_lets_encrypt_tls_issuer == true && length(var.tls_lets_encrypt_zone_rg_name) > 0)
    error_message = "You must provide a value for tls_lets_encrypt_zone_rg_name when enable_lets_encrypt_tls_issuer is true."
  }
}

variable "tls_lets_encrypt_workload_identity_client_id" {
  type        = string
  description = "Client id for cert-manager workload identity (Let's Encrypt DNS issuer)"
  default     = ""
  validation {
    condition     = var.enable_lets_encrypt_tls_issuer == false || (var.enable_lets_encrypt_tls_issuer == true && length(var.tls_lets_encrypt_workload_identity_client_id) > 0)
    error_message = "You must provide a value for tls_lets_encrypt_workload_identity_client_id when enable_lets_encrypt_tls_issuer is true."
  }
}
