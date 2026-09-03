variable "admin_group_object_ids" {
  type        = list(string)
  description = "List of group object IDs to get admin access to the cluster"
  validation {
    condition     = length(var.admin_group_object_ids) > 0
    error_message = "You must provide at least one admin group object ID."
  }
}

variable "vnet_network_contributor_object_ids" {
  type        = list(string)
  default     = []
  description = "List of service principal object IDs to assign the Network Contributor role on the AKS VNet."
}

variable "private_dns_zone_contributor_object_ids" {
  type        = list(string)
  default     = []
  description = "List of principal object IDs to assign the Private DNS Zone Contributor role on the AKS node resource group."
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

variable "enable_keda" {
  type        = bool
  default     = false
  description = "Enable KEDA (Kubernetes Event-driven Autoscaling) for workload autoscaling"
}

variable "aks_local_account_disabled" {
  type        = bool
  default     = true
  description = "Disable local account for the AKS cluster. When true, only Azure AD authentication is allowed."
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
    condition     = can(regex("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", var.kubernetes_version))
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
    zones                = optional(list(string), ["1", "2", "3"])
  })
  description = "Configuration for the system node pool. Set ephemeral_os_disk=true for VMs with sufficient cache/NVMe storage. When auto_scaling_enabled=true, node_count is optional (initial count), and min_count/max_count are required. When auto_scaling_enabled=false, node_count is required. zones defaults to all three Norway East availability zones; changing it on an existing cluster cycles the system node pool."
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
  description = "Configuration for additional node pools. Each key becomes the node pool name (max 10 chars, lowercase alphanumeric). Set ephemeral_os_disk=true for VMs with sufficient cache/NVMe storage. When auto_scaling_enabled=true, node_count is optional (initial count), and min_count/max_count are required. When auto_scaling_enabled=false, node_count is required."
  validation {
    condition = alltrue([
      for k, v in var.node_pool_configs : length(k) <= 10 && can(regex("^[a-z][a-z0-9]*$", k))
    ])
    error_message = "Node pool names must be max 10 characters (to allow for temporary rotation name suffix), start with a letter, and contain only lowercase alphanumeric characters."
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

variable "load_balancer_outbound_ports_allocated" {
  type        = number
  default     = 0
  description = "Number of SNAT ports allocated per node on the cluster outbound load balancer. 0 lets Azure size the allocation from the backend pool, which reshuffles ports as the cluster crosses node-count boundaries. AKS applies this to the IPv4 and IPv6 outbound rules alike, so a fixed value must satisfy ports_per_node * max_nodes <= 64000 * outbound_ip_count for each family independently, counting surge nodes. The default matches the provider default, so existing clusters are unaffected."
  validation {
    condition     = var.load_balancer_outbound_ports_allocated >= 0 && var.load_balancer_outbound_ports_allocated <= 64000 && floor(var.load_balancer_outbound_ports_allocated) == var.load_balancer_outbound_ports_allocated
    error_message = "load_balancer_outbound_ports_allocated must be a whole number between 0 and 64000."
  }
  validation {
    condition     = var.load_balancer_outbound_ports_allocated % 8 == 0
    error_message = "load_balancer_outbound_ports_allocated must be a multiple of 8."
  }
}

variable "load_balancer_idle_timeout_in_minutes" {
  type        = number
  default     = 30
  description = "Outbound flow idle timeout in minutes for the cluster load balancer. The default matches the provider default, so existing clusters are unaffected."
  validation {
    condition     = var.load_balancer_idle_timeout_in_minutes >= 4 && var.load_balancer_idle_timeout_in_minutes <= 100 && floor(var.load_balancer_idle_timeout_in_minutes) == var.load_balancer_idle_timeout_in_minutes
    error_message = "load_balancer_idle_timeout_in_minutes must be a whole number between 4 and 100."
  }
}

variable "node_sysctl_config" {
  type = object({
    net_core_somaxconn           = optional(number)
    net_ipv4_tcp_max_syn_backlog = optional(number)
    net_core_netdev_max_backlog  = optional(number)
  })
  default     = null
  description = "Connection backlog sysctls applied to the system pool and all node pools via linux_os_config. Null (the default) emits no block, leaving nodes on the AzureLinux defaults. All three govern IPv4 and IPv6 TCP alike - net.ipv4.tcp_max_syn_backlog is shared across both families despite its name, and AKS exposes no net.ipv6.* sysctls. Setting this on an existing cluster cycles every node pool without cordon and drain."
  validation {
    condition     = var.node_sysctl_config == null || try(var.node_sysctl_config.net_core_somaxconn, null) == null || (var.node_sysctl_config.net_core_somaxconn >= 4096 && var.node_sysctl_config.net_core_somaxconn <= 3240000)
    error_message = "net_core_somaxconn must be between 4096 and 3240000."
  }
  validation {
    condition     = var.node_sysctl_config == null || try(var.node_sysctl_config.net_ipv4_tcp_max_syn_backlog, null) == null || (var.node_sysctl_config.net_ipv4_tcp_max_syn_backlog >= 128 && var.node_sysctl_config.net_ipv4_tcp_max_syn_backlog <= 3240000)
    error_message = "net_ipv4_tcp_max_syn_backlog must be between 128 and 3240000."
  }
  validation {
    condition     = var.node_sysctl_config == null || try(var.node_sysctl_config.net_core_netdev_max_backlog, null) == null || (var.node_sysctl_config.net_core_netdev_max_backlog >= 1000 && var.node_sysctl_config.net_core_netdev_max_backlog <= 3240000)
    error_message = "net_core_netdev_max_backlog must be between 1000 and 3240000."
  }
}

variable "ddos_protection_plan_id" {
  type        = string
  default     = ""
  description = "Resource ID of an existing Azure DDoS Network Protection plan to associate with the AKS VNet. Covers every public IP in the VNet, IPv4 and IPv6 alike. Empty (the default) emits no ddos_protection_plan block, so existing VNets are unaffected. Enable at VNet creation so adaptive tuning can learn the traffic baseline before production traffic arrives."
}

variable "subnet_service_endpoints" {
  type        = list(string)
  default     = []
  description = "List of service endpoints to associate with the AKS subnets"
}

variable "private_endpoint_subnet_prefixes" {
  type        = list(string)
  default     = []
  description = "Address prefixes for the private endpoints subnet (IPv4 only). If empty, no subnet is created."
  validation {
    condition     = alltrue([for prefix in var.private_endpoint_subnet_prefixes : !strcontains(prefix, ":")])
    error_message = "private_endpoint_subnet_prefixes only supports IPv4 CIDR prefixes. IPv6 prefixes (containing ':') are not allowed."
  }
}

variable "api_server_subnet_prefixes" {
  type        = list(string)
  description = "Address prefixes for the API server subnet. Must contain exactly one IPv4 prefix (/28 minimum, larger networks accepted). Dual-stack and IPv6 are not supported."
  validation {
    condition     = length(var.api_server_subnet_prefixes) == 1
    error_message = "api_server_subnet_prefixes must contain exactly one prefix."
  }
  validation {
    condition     = !can(regex(":", var.api_server_subnet_prefixes[0]))
    error_message = "api_server_subnet_prefixes must be an IPv4 prefix. IPv6 and dual-stack are not supported."
  }
  validation {
    condition     = try(tonumber(split("/", var.api_server_subnet_prefixes[0])[1]) <= 28, false)
    error_message = "api_server_subnet_prefixes IPv4 prefix must be /28 or larger (e.g. /28, /27, /24)."
  }
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
