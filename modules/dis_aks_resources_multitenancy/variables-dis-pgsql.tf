variable "enable_dis_pgsql_operator" {
  type        = bool
  default     = false
  description = "Enable the dis-pgsql operator in the cluster."
}

variable "obs_tenant_id" {
  type        = string
  description = "Tenant id for the observability app."
  default     = ""
  validation {
    condition     = var.enable_dis_pgsql_operator == false || (var.enable_dis_pgsql_operator == true && length(var.obs_tenant_id) > 0)
    error_message = "You must provide a value for obs_tenant_id when enable_dis_pgsql_operator is true."
  }
}

variable "dis_resource_group_name" {
  type        = string
  description = "Name of the resource group where DIS operators create their resources."
  default     = ""
  validation {
    condition     = (var.enable_dis_pgsql_operator == false && var.enable_dis_vault_operator == false) || length(var.dis_resource_group_name) > 0
    error_message = "You must provide a value for dis_resource_group_name when enable_dis_pgsql_operator or enable_dis_vault_operator is true."
  }
}

variable "dis_db_vnet_name" {
  type        = string
  description = "Name of the VNet hosting DIS database resources."
  default     = ""
  validation {
    condition     = var.enable_dis_pgsql_operator == false || (var.enable_dis_pgsql_operator == true && length(var.dis_db_vnet_name) > 0)
    error_message = "You must provide a value for dis_db_vnet_name when enable_dis_pgsql_operator is true."
  }
}

variable "aks_workpool_vnet_name" {
  type        = string
  description = "Name of the AKS workpool VNet."
  default     = ""
  validation {
    condition     = var.enable_dis_pgsql_operator == false || (var.enable_dis_pgsql_operator == true && length(var.aks_workpool_vnet_name) > 0)
    error_message = "You must provide a value for aks_workpool_vnet_name when enable_dis_pgsql_operator is true."
  }
}

variable "aks_resource_group" {
  type        = string
  description = "AKS resource group name."
  default     = ""
  validation {
    condition     = var.enable_dis_pgsql_operator == false || (var.enable_dis_pgsql_operator == true && length(var.aks_resource_group) > 0)
    error_message = "You must provide a value for aks_resource_group when enable_dis_pgsql_operator is true."
  }
}

variable "dis_pgsql_uami_client_id" {
  type        = string
  description = "Client id for the dis-pgsql workload identity."
  default     = ""
  validation {
    condition     = var.enable_dis_pgsql_operator == false || (var.enable_dis_pgsql_operator == true && length(var.dis_pgsql_uami_client_id) > 0)
    error_message = "You must provide a value for dis_pgsql_uami_client_id when enable_dis_pgsql_operator is true."
  }
}
