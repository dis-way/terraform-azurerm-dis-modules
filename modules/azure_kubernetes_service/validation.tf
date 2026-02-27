# Cross-variable validation using check blocks (Terraform 1.5+)
# These validate relationships between variables that cannot be checked
# within individual variable validation blocks.

check "node_pool_subnet_prefixes_match_configs" {
  assert {
    condition = alltrue([
      for k in keys(var.node_pool_configs) : contains(keys(var.node_pool_subnet_prefixes), k)
    ])
    error_message = "Each node pool in node_pool_configs must have a corresponding entry in node_pool_subnet_prefixes. Missing: ${join(", ", [for k in keys(var.node_pool_configs) : k if !contains(keys(var.node_pool_subnet_prefixes), k)])}"
  }
}

check "api_server_subnet_prefixes_required" {
  assert {
    condition     = !var.enable_api_server_vnet_integration || length(var.api_server_subnet_prefixes) >= 2
    error_message = "api_server_subnet_prefixes must contain at least two prefixes (one IPv4 /28 and one IPv6 /64) when enable_api_server_vnet_integration is true."
  }
}

check "api_server_subnet_ipv6_prefix_length" {
  assert {
    condition = alltrue([
      for prefix in var.api_server_subnet_prefixes :
      !can(regex(":", prefix)) || endswith(prefix, "/64")
    ])
    error_message = "IPv6 address prefixes in api_server_subnet_prefixes must use /64 prefix length (Azure requirement for IPv6 subnets)."
  }
}

check "node_pool_subnet_prefixes_no_extras" {
  assert {
    condition = alltrue([
      for k in keys(var.node_pool_subnet_prefixes) : contains(keys(var.node_pool_configs), k)
    ])
    error_message = "Each key in node_pool_subnet_prefixes must have a corresponding node pool in node_pool_configs. Extra keys: ${join(", ", [for k in keys(var.node_pool_subnet_prefixes) : k if !contains(keys(var.node_pool_configs), k)])}"
  }
}
