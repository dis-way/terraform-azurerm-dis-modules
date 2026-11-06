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

variable "flux_dispatch_tokens" {
  type = map(object({
    github_repository_name = string
    token_namespace        = string
    token_secret_name      = string
  }))
  default     = {}
  description = "GitHub tokens for Flux githubdispatch Providers (RFC 0019), keyed by a mapping name of at most 15 characters. For each mapping, platform-system renews a contents: write token for github_repository_name, a repository in the App installation named without its owner, and copies it to the Secret token_secret_name in token_namespace. Needs flux_dispatch_github_app_id, flux_dispatch_github_app_installation_id and the App private key in the dis-system Key Vault; see the README."

  # The key names the kustomizations flux-dispatch-<key> and flux-dispatch-<key>-secrets,
  # which must fit in the 37 characters AKS leaves after "external-secrets-operator".
  validation {
    condition     = alltrue([for name in keys(var.flux_dispatch_tokens) : can(regex("^[a-z0-9]([-a-z0-9]{0,13}[a-z0-9])?$", name))])
    error_message = "flux_dispatch_tokens keys must be 1-15 lowercase letters, digits and dashes, starting and ending with a letter or digit."
  }

  validation {
    condition = alltrue([
      for token in values(var.flux_dispatch_tokens) :
      can(regex("^[A-Za-z0-9._-]+$", token.github_repository_name)) &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", token.token_namespace)) &&
      can(regex("^[a-z0-9]([-.a-z0-9]*[a-z0-9])?$", token.token_secret_name))
    ])
    error_message = "Each flux_dispatch_tokens entry needs github_repository_name without the owner, e.g. dialogporten, and Kubernetes names in token_namespace and token_secret_name."
  }

  validation {
    condition     = length(var.flux_dispatch_tokens) == 0 || (can(regex("^[0-9]+$", var.flux_dispatch_github_app_id)) && can(regex("^[0-9]+$", var.flux_dispatch_github_app_installation_id)))
    error_message = "flux_dispatch_tokens needs flux_dispatch_github_app_id and flux_dispatch_github_app_installation_id set to the numeric App and installation IDs."
  }
}

variable "flux_dispatch_github_app_id" {
  type        = string
  default     = ""
  description = "App ID of the shared GitHub App that generates the flux_dispatch_tokens. Written to the dis-system Key Vault as flux-dispatch-github-app-id. Required when flux_dispatch_tokens is set."
}

variable "flux_dispatch_github_app_installation_id" {
  type        = string
  default     = ""
  description = "Installation ID of the flux_dispatch_github_app_id App. Written to the dis-system Key Vault as flux-dispatch-github-app-installation-id. Required when flux_dispatch_tokens is set."
}
