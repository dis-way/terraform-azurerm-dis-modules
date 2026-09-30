variable "dis_system_kv_client_id" {
  type        = string
  description = "Client ID of the dis-system Key Vault reader identity (dis_system_kv_reader_client_id output of the dis_system_kv module). When set together with dis_system_kv_uri, the ESO post-deploy layer creating the dis-system-store SecretStore in flux-system is deployed."
  default     = ""
}

variable "dis_system_kv_uri" {
  type        = string
  description = "Vault URI of the dis-system Key Vault (dis_system_kv_uri output of the dis_system_kv module)."
  default     = ""
  validation {
    condition     = (length(trimspace(var.dis_system_kv_client_id)) > 0) == (length(trimspace(var.dis_system_kv_uri)) > 0)
    error_message = "dis_system_kv_client_id and dis_system_kv_uri must either both be set or both be empty."
  }
  validation {
    condition     = length(trimspace(var.dis_system_kv_uri)) == 0 || length(trimspace(var.tenant_id)) > 0
    error_message = "You must provide a value for tenant_id when dis_system_kv_uri is set."
  }
}
