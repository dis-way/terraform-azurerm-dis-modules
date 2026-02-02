variable "app_insights_connection_string" {
  type        = string
  sensitive   = true
  description = "Connection string of an Application Insights where logs and traces are sendt."
  validation {
    condition     = trimspace(var.app_insights_connection_string) != ""
    error_message = "app_insights_connection_string must be non-empty"
  }
}

variable "azurerm_kubernetes_cluster_id" {
  type        = string
  description = "AKS cluster resource id"
  validation {
    condition     = trimspace(var.azurerm_kubernetes_cluster_id) != ""
    error_message = "You must provide a non-empty value for azurerm_kubernetes_cluster_id"
  }
}

variable "azurerm_resource_group_obs_name" {
  type        = string
  description = "Name of the observability resource group where all the resources will be placed."
}

variable "ci_service_principal_object_id" {
  type        = string
  description = "Object ID of the CI service principal used for role assignments."
  validation {
    condition     = length(trimspace(var.ci_service_principal_object_id)) > 0
    error_message = "You must provide a value for ci_service_principal_object_id."
  }
}

variable "environment" {
  type        = string
  description = "Environment for resources"
  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "You must provide a value for environment."
  }
}

variable "localtags" {
  type        = map(string)
  description = "A map of tags to assign to the created resources."
  default     = {}
}

variable "location" {
  type        = string
  default     = "norwayeast"
  description = "Region for resources"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of an existing Log Analytics Workspace when reusing."
  validation {
    condition     = trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be non-empty."
  }
}

variable "monitor_workspace_id" {
  type        = string
  description = "ID of an existing Azure Monitor Workspace when reusing."
  validation {
    condition     = trimspace(var.monitor_workspace_id) != ""
    error_message = "monitor_workspace_id must be non-empty."
  }
}

variable "monitor_workspace_name" {
  type        = string
  description = "Name of an existing Azure Monitor Workspace when reusing."
  validation {
    condition     = trimspace(var.monitor_workspace_name) != ""
    error_message = "monitor_workspace_name must be non-empty."
  }
}

variable "oidc_issuer_url" {
  type        = string
  description = "Oidc issuer url needed for federation"
  validation {
    condition     = length(trimspace(var.oidc_issuer_url)) > 0
    error_message = "You must provide a value for oidc_issuer_url."
  }
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
  validation {
    condition     = length(trimspace(var.prefix)) > 0
    error_message = "You must provide a value for prefix for name generation."
  }
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for resource deployments."
  validation {
    condition     = length(trimspace(var.subscription_id)) > 0
    error_message = "You must provide a value for subscription_id."
  }
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for resource configuration."
  validation {
    condition     = length(trimspace(var.tenant_id)) > 0
    error_message = "You must provide a value for tenant_id."
  }
}

variable "enable_lakmus" {
  type        = bool
  default     = true
  description = "Deploy the resources needed by lakmus"
}
