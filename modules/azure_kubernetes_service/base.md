### Minimal usage example
```hcl
module "aks" {
  source = "./modules/azure_kubernetes_service"

  # Required identifiers
  prefix          = "myapp"
  environment     = "dev"

  # Kubernetes
  kubernetes_version     = "1.30"
  admin_group_object_ids = ["00000000-0000-0000-0000-000000000001"]

  # Network
  vnet_address_space = ["10.0.0.0/16", "fd00::/48"]

  # System pool
  system_pool_config = {
    vm_size              = "Standard_D4ads_v6"
    auto_scaling_enabled = true
    node_count           = 2
    min_count            = 2
    max_count            = 3
    ephemeral_os_disk    = true
  }
  system_pool_subnet_prefixes = ["10.0.0.0/24", "fd00:0:0:1::/64"]

  # Node pools
  node_pool_configs = {
    workpool = {
      vm_size              = "Standard_D8ads_v6"
      auto_scaling_enabled = true
      node_count           = 2
      min_count            = 1
      max_count            = 10
      ephemeral_os_disk    = true
    }
    daemonpool = {
      vm_size              = "Standard_D4ads_v6"
      auto_scaling_enabled = false
      node_count           = 3
      min_count            = 3
      max_count            = 3
      node_taints          = ["dedicated=daemonset:NoSchedule"]
      node_labels          = { "workload" = "daemonset" }
      ephemeral_os_disk    = true
    }
  }
  node_pool_subnet_prefixes = {
    workpool   = ["10.0.1.0/24", "fd00:0:0:2::/64"]
    daemonpool = ["10.0.2.0/24", "fd00:0:0:3::/64"]
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```
