variable "enable_dis_vault_operator" {
  type        = bool
  default     = false
  description = "Enable the dis-vault operator in the cluster."
}

variable "dis_vault_location" {
  type        = string
  description = "Azure location for DIS Vault resources."
  default     = ""
  validation {
    condition     = var.enable_dis_vault_operator == false || (var.enable_dis_vault_operator == true && length(var.dis_vault_location) > 0)
    error_message = "You must provide a value for dis_vault_location when enable_dis_vault_operator is true."
  }
}

variable "dis_vault_environment" {
  type        = string
  description = "Environment name passed to DIS Vault."
  default     = ""
  validation {
    condition     = var.enable_dis_vault_operator == false || (var.enable_dis_vault_operator == true && length(var.dis_vault_environment) > 0)
    error_message = "You must provide a value for dis_vault_environment when enable_dis_vault_operator is true."
  }
}

variable "dis_vault_aks_subnet_ids" {
  type        = string
  description = "AKS subnet IDs passed to DIS Vault."
  default     = ""
  validation {
    condition     = var.enable_dis_vault_operator == false || (var.enable_dis_vault_operator == true && length(var.dis_vault_aks_subnet_ids) > 0)
    error_message = "You must provide a value for dis_vault_aks_subnet_ids when enable_dis_vault_operator is true."
  }
}

variable "dis_vault_vpn_exit_node_subnet_id" {
  type        = string
  description = "Optional VPN exit node subnet ID passed to DIS Vault."
  default     = ""
}
