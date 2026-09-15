variable "prefix" {
  description = "A prefix to be used for naming resources."
  type        = string

  # The Key Vault is named "<prefix>-<environment>-<random suffix>" and Azure limits
  # Key Vault names to 24 characters. Cross-variable validation requires Terraform >= 1.9.
  validation {
    condition     = length("${var.prefix}-${var.environment}-") + var.key_vault_name_random_suffix_length <= 24
    error_message = "Key Vault name \"${var.prefix}-${var.environment}-<${var.key_vault_name_random_suffix_length} random chars>\" would be ${length("${var.prefix}-${var.environment}-") + var.key_vault_name_random_suffix_length} characters, exceeding the Azure maximum of 24. Shorten prefix, environment or key_vault_name_random_suffix_length."
  }
}

variable "key_vault_name_random_suffix_length" {
  description = "Number of random characters appended to the Key Vault name to keep it globally unique."
  type        = number
  default     = 6
}

variable "environment" {
  description = "The environment for which the dis-system-kv is being created."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  default     = "norwayeast"
  type        = string
}

variable "azurerm_kubernetes_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL of the AKS cluster."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources created."
  type        = map(string)
  default     = {}
}

variable "dis_system_kv_namespace" {
  description = "Name of the namespace where dis-system kv sync components are deployed"
  type        = string
  default     = "platform-system"
}

variable "dis_system_kv_service_account_name" {
  description = "Name of service account used to sync configs from dis-system key vault"
  type        = string
  default     = "dis-secret-sync-sa"
}

variable "resource_group_name" {
  description = "Name of the resource group where the resources are deployed."
  type        = string
}

variable "tenant_id" {
  description = "Tenant id where everything is deployed"
  type        = string
}

variable "override_user_assigned_identity_name" {
  description = "Override the default name of the User Assigned Managed Identity."
  type        = string
  default     = ""
}

variable "ci_service_principal_object_id" {
  type        = string
  description = "Object ID of the CI service principal used for role assignments."
  validation {
    condition     = length(trimspace(var.ci_service_principal_object_id)) > 0
    error_message = "You must provide a value for ci_service_principal_object_id."
  }
}

variable "secrets" {
  description = "Secrets to create in the dis-system Key Vault, keyed by Key Vault secret name. Values are sent via the write-only API so they are not persisted in Terraform state."
  type        = map(string)
  sensitive   = true
  default     = {}

  validation {
    condition = alltrue([
      for name in nonsensitive(keys(var.secrets)) :
      can(regex("^[0-9a-zA-Z-]{1,127}$", name))
    ])
    error_message = "Key Vault secret names may contain only letters, digits and dashes, and must be 1-127 characters long."
  }
}

variable "secret_versions" {
  description = "Non-sensitive version marker for each secret value. Increment the number when a secret value changes so Terraform updates the Key Vault secret without persisting the secret value in state."
  type        = map(number)
  default     = {}
}
