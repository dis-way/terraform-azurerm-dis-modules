variable "dis_system_kv_client_id" {
  type        = string
  description = "Client ID of the dis-system Key Vault reader identity (dis_system_kv_reader_client_id output of the dis_system_kv module). Used by the dis-system-store SecretStore in platform-system."
}

variable "dis_system_kv_id" {
  type        = string
  description = "Resource ID of the dis-system Key Vault (dis_system_kv_id output of the dis_system_kv module). Every postBuild.substitute variable of the flux configurations is written to it as a secret, see flux-substitute-secrets.tf."
}

variable "dis_system_kv_uri" {
  type        = string
  description = "Vault URI of the dis-system Key Vault (dis_system_kv_uri output of the dis_system_kv module)."
}

variable "enable_central_accesstoken" {
  type        = bool
  default     = false
  description = "Deploy the multitenancy/secrets and multitenancy/central-accesstoken layers of external-secrets-operator: the ApplicationIdentity central-accesstoken-eso in platform-system and the ClusterSecretStore central-accesstoken-store, usable only from namespaces labeled accesstoken.dis.altinn.cloud/enabled=true. The store stays NotReady until the managed identity dis-identity-operator creates for central-accesstoken-eso is granted Key Vault Secrets User on the token secret in central_accesstoken_kv_uri. The vault is shared, so grant it on that secret only."

  # azurerm does not accept "" as a secret value, and an unset CENTRAL_ACCESSTOKEN_KV_URL
  # would give the ClusterSecretStore an empty vaultUrl.
  validation {
    condition     = var.enable_central_accesstoken == false || try(length(trimspace(var.central_accesstoken_kv_uri)) > 0, false)
    error_message = "enable_central_accesstoken needs central_accesstoken_kv_uri set to the vault URI of the Key Vault holding the central access token."
  }
}

variable "central_accesstoken_kv_uri" {
  type        = string
  default     = ""
  description = "Vault URI of the Key Vault holding the central access token, e.g. https://<name>.vault.azure.net/. Written to the dis-system Key Vault as external-secrets-operator-central-accesstoken-kv-url. Required when enable_central_accesstoken is true."

  validation {
    condition     = var.central_accesstoken_kv_uri == "" || can(regex("^https://[0-9A-Za-z-]+\\.vault\\.azure\\.net/?$", var.central_accesstoken_kv_uri))
    error_message = "central_accesstoken_kv_uri must be a Key Vault URI, e.g. https://<name>.vault.azure.net/."
  }
}
