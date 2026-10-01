variable "dis_system_kv_client_id" {
  type        = string
  description = "Client ID of the dis-system Key Vault reader identity (dis_system_kv_reader_client_id output of the dis_system_kv module). Used by the dis-system-store SecretStore in flux-system."
}

variable "dis_system_kv_uri" {
  type        = string
  description = "Vault URI of the dis-system Key Vault (dis_system_kv_uri output of the dis_system_kv module)."
}
