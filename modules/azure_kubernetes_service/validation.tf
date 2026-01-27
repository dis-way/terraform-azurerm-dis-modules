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

check "node_pool_subnet_prefixes_no_extras" {
  assert {
    condition = alltrue([
      for k in keys(var.node_pool_subnet_prefixes) : contains(keys(var.node_pool_configs), k)
    ])
    error_message = "Each key in node_pool_subnet_prefixes must have a corresponding node pool in node_pool_configs. Extra keys: ${join(", ", [for k in keys(var.node_pool_subnet_prefixes) : k if !contains(keys(var.node_pool_configs), k)])}"
  }
}
