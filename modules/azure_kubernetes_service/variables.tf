variable "admin_group_object_ids" {
  type        = list(string)
  description = "List of group object IDs to get admin access to the cluster"
  validation {
    condition     = length(var.admin_group_object_ids) > 0
    error_message = "You must provide at least one admin group object ID."
  }
}

variable "aks_acrpull_scopes" {
  type        = list(string)
  default     = []
  description = "List of AKS ACR pull scopes"
}

variable "aks_sku_tier" {
  type        = string
  default     = "Free"
  description = "Kubernetes SKU"
}

variable "aks_user_role_scopes" {
  type        = list(string)
  default     = []
  description = "List of groups to get user role scopes for AKS"
}

variable "api_server_authorized_ip_ranges" {
  type = object({
    ipv4 = list(string)
    ipv6 = list(string)
  })
  default = {
    ipv4 = []
    ipv6 = []
  }
  description = <<-EOT
    Authorized IP ranges (CIDR notation) that can access the Kubernetes API server.

    WARNING: If left empty, API server is publicly accessible.
    For production, always specify authorized ranges.

    Example:
      ipv4 = ["10.0.0.0/8", "203.0.113.0/24"]
      ipv6 = ["2001:db8::/32"]
  EOT
  validation {
    condition = alltrue([
      for cidr in var.api_server_authorized_ip_ranges.ipv4 : can(cidrhost(cidr, 0))
    ])
    error_message = "All IPv4 values must be valid CIDR notation (e.g., '10.0.0.0/8', '203.0.113.0/24')."
  }
  validation {
    condition = alltrue([
      for cidr in var.api_server_authorized_ip_ranges.ipv6 : can(cidrhost(cidr, 0))
    ])
    error_message = "All IPv6 values must be valid CIDR notation (e.g., '2001:db8::/32')."
  }
}

variable "enable_keda" {
  type        = bool
  default     = false
  description = "Enable KEDA (Kubernetes Event-driven Autoscaling) for workload autoscaling"
}

variable "enable_multi_tenancy" {
  type        = bool
  default     = false
  description = "Enable multi tenancy in the cluster"
}

variable "environment" {
  type        = string
  description = "Environment for resources (required, max 4 characters). Combined with prefix, must not exceed 12 characters for storage account naming."
  validation {
    condition     = length(var.environment) > 0
    error_message = "You must provide a value for environment."
  }
  validation {
    condition     = length(var.environment) <= 4
    error_message = "Environment must be 4 characters or less (e.g., 'dev', 'prod') to avoid exceeding Azure resource name limits."
  }
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  validation {
    condition     = length(var.kubernetes_version) > 0
    error_message = "You must provide kubernetes version in format x.y or x.y.z."
  }
}

variable "location" {
  type        = string
  default     = "norwayeast"
  description = "Default region for resources"
}

variable "system_pool_config" {
  type = object({
    vm_size              = string
    auto_scaling_enabled = bool
    node_count           = optional(number)
    min_count            = optional(number)
    max_count            = optional(number)
    ephemeral_os_disk    = optional(bool, false)
  })
  description = "Configuration for the system node pool. Set ephemeral_os_disk=true for VMs with sufficient cache/NVMe storage. When auto_scaling_enabled=true, node_count is optional (initial count), and min_count/max_count are required. When auto_scaling_enabled=false, node_count is required."
  validation {
    condition     = var.system_pool_config.auto_scaling_enabled || var.system_pool_config.node_count != null
    error_message = "node_count is required when auto_scaling_enabled is false."
  }
  validation {
    condition     = !var.system_pool_config.auto_scaling_enabled || (var.system_pool_config.min_count != null && var.system_pool_config.min_count >= 1)
    error_message = "min_count must be set and at least 1 for system pool when auto_scaling_enabled is true."
  }
  validation {
    condition     = !var.system_pool_config.auto_scaling_enabled || (var.system_pool_config.max_count != null && var.system_pool_config.max_count >= var.system_pool_config.min_count)
    error_message = "max_count must be set and greater than or equal to min_count when auto_scaling_enabled is true."
  }
  validation {
    condition     = var.system_pool_config.node_count == null || !var.system_pool_config.auto_scaling_enabled || (var.system_pool_config.node_count >= var.system_pool_config.min_count && var.system_pool_config.node_count <= var.system_pool_config.max_count)
    error_message = "node_count must be between min_count and max_count when both are specified and auto_scaling_enabled is true."
  }
}

variable "node_pool_configs" {
  type = map(object({
    vm_size              = string
    auto_scaling_enabled = bool
    node_count           = optional(number)
    min_count            = optional(number)
    max_count            = optional(number)
    os_sku               = optional(string, "AzureLinux")
    max_pods             = optional(number, 200)
    zones                = optional(list(string), ["1", "2", "3"])
    node_labels          = optional(map(string), {})
    node_taints          = optional(list(string), [])
    ephemeral_os_disk    = optional(bool, false)
  }))
  default     = {}
  description = "Configuration for additional node pools. Each key becomes the node pool name (max 12 chars, lowercase alphanumeric). Set ephemeral_os_disk=true for VMs with sufficient cache/NVMe storage. When auto_scaling_enabled=true, node_count is optional (initial count), and min_count/max_count are required. When auto_scaling_enabled=false, node_count is required."
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : length(k) <= 12 && can(regex("^[a-z][a-z0-9]*$", k))
    ])
    error_message = "Node pool names must be max 12 characters, start with a letter, and contain only lowercase alphanumeric characters."
  }
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : v.auto_scaling_enabled || v.node_count != null
    ])
    error_message = "node_count is required when auto_scaling_enabled is false."
  }
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : !v.auto_scaling_enabled || (v.min_count != null && v.min_count >= 0)
    ])
    error_message = "min_count must be set and at least 0 when auto_scaling_enabled is true."
  }
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : !v.auto_scaling_enabled || (v.max_count != null && v.max_count >= v.min_count)
    ])
    error_message = "max_count must be set and greater than or equal to min_count when auto_scaling_enabled is true."
  }
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : v.node_count == null || !v.auto_scaling_enabled || (v.node_count >= v.min_count && v.node_count <= v.max_count)
    ])
    error_message = "node_count must be between min_count and max_count when both are specified and auto_scaling_enabled is true."
  }
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names (required, max 8 characters). Combined with environment, must not exceed 12 characters for storage account naming."
  validation {
    condition     = length(var.prefix) > 0
    error_message = "You must provide a value for prefix for name generation."
  }
  validation {
    condition     = length(var.prefix) <= 8
    error_message = "Prefix must be 8 characters or less to avoid exceeding Azure storage account name limits (24 char max)."
  }
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "system_pool_subnet_prefixes" {
  type        = list(string)
  description = "Address prefixes for the system pool subnet (IPv4 and IPv6)"
  validation {
    condition     = length(var.system_pool_subnet_prefixes) > 0
    error_message = "You must provide at least one address prefix for the system pool subnet."
  }
}

variable "node_pool_subnet_prefixes" {
  type        = map(list(string))
  default     = {}
  description = "Map of node pool names to their subnet address prefixes. Keys must match node_pool_configs keys."
}

variable "subnet_service_endpoints" {
  type        = list(string)
  default     = []
  description = "List of service endpoints to associate with the AKS subnets"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "VNet address space"
  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "You must provide a vnet address space with ipv4 and ipv6 addresses."
  }
}

# Optional explicit variables to override values derived from prefix and environment
variable "azurerm_kubernetes_cluster_aks_dns_service_ip" {
  type        = string
  default     = ""
  description = "Optional explicit aks dns service ip"
}

variable "azurerm_kubernetes_cluster_aks_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the AKS cluster"
}

variable "azurerm_kubernetes_cluster_aks_pod_cidrs" {
  type        = list(string)
  default     = []
  description = "Optional explicit aks pod cidrs"
}

variable "azurerm_kubernetes_cluster_aks_service_cidrs" {
  type        = list(string)
  default     = []
  description = "Optional explicit aks service cidrs"
}

variable "azurerm_log_analytics_workspace_aks_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the log analytics workspace"
}

variable "azurerm_public_ip_prefix_prefix4_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the public ipv4 prefix"
}

variable "azurerm_public_ip_prefix_prefix6_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the public ipv6 prefix"
}

variable "azurerm_resource_group_aks_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the AKS resource group"
}

variable "azurerm_resource_group_dis_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the DIS resource group"
}

variable "azurerm_resource_group_monitor_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the monitor resource group"
}

variable "azurerm_storage_account_aks_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the AKS Log storage account (must be 3-24 characters, lowercase alphanumeric only)"
  validation {
    condition     = var.azurerm_storage_account_aks_name == "" || (length(var.azurerm_storage_account_aks_name) >= 3 && length(var.azurerm_storage_account_aks_name) <= 24 && can(regex("^[a-z0-9]+$", var.azurerm_storage_account_aks_name)))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "azurerm_virtual_network_aks_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the AKS virtual network"
}

variable "azurerm_virtual_public_ip_pip4_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the public ipv4"
}

variable "azurerm_virtual_public_ip_pip6_name" {
  type        = string
  default     = ""
  description = "Optional explicit name of the public ipv6"
}
