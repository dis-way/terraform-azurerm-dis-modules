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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_extension.flux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension) | resource |
| [azurerm_kubernetes_cluster_node_pool.pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_workspace.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_data_collection_rule.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.pip4](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.pip6](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip_prefix.prefix4](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_public_ip_prefix.prefix6](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.dis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks_acrpull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_user_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.aks_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.node_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.system_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.aks_log](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | List of group object IDs to get admin access to the cluster | `list(string)` | n/a | yes |
| <a name="input_aks_acrpull_scopes"></a> [aks\_acrpull\_scopes](#input\_aks\_acrpull\_scopes) | List of AKS ACR pull scopes | `list(string)` | `[]` | no |
| <a name="input_aks_sku_tier"></a> [aks\_sku\_tier](#input\_aks\_sku\_tier) | Kubernetes SKU | `string` | `"Free"` | no |
| <a name="input_aks_user_role_scopes"></a> [aks\_user\_role\_scopes](#input\_aks\_user\_role\_scopes) | List of groups to get user role scopes for AKS | `list(string)` | `[]` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | Authorized IP ranges (CIDR notation) that can access the Kubernetes API server.<br/><br/>WARNING: If left empty, API server is publicly accessible.<br/>For production, always specify authorized ranges.<br/><br/>Example:<br/>  ipv4 = ["10.0.0.0/8", "203.0.113.0/24"]<br/>  ipv6 = ["2001:db8::/32"] | <pre>object({<br/>    ipv4 = list(string)<br/>    ipv6 = list(string)<br/>  })</pre> | <pre>{<br/>  "ipv4": [],<br/>  "ipv6": []<br/>}</pre> | no |
| <a name="input_azurerm_kubernetes_cluster_aks_dns_service_ip"></a> [azurerm\_kubernetes\_cluster\_aks\_dns\_service\_ip](#input\_azurerm\_kubernetes\_cluster\_aks\_dns\_service\_ip) | Optional explicit aks dns service ip | `string` | `""` | no |
| <a name="input_azurerm_kubernetes_cluster_aks_name"></a> [azurerm\_kubernetes\_cluster\_aks\_name](#input\_azurerm\_kubernetes\_cluster\_aks\_name) | Optional explicit name of the AKS cluster | `string` | `""` | no |
| <a name="input_azurerm_kubernetes_cluster_aks_pod_cidrs"></a> [azurerm\_kubernetes\_cluster\_aks\_pod\_cidrs](#input\_azurerm\_kubernetes\_cluster\_aks\_pod\_cidrs) | Optional explicit aks pod cidrs | `list(string)` | `[]` | no |
| <a name="input_azurerm_kubernetes_cluster_aks_service_cidrs"></a> [azurerm\_kubernetes\_cluster\_aks\_service\_cidrs](#input\_azurerm\_kubernetes\_cluster\_aks\_service\_cidrs) | Optional explicit aks service cidrs | `list(string)` | `[]` | no |
| <a name="input_azurerm_log_analytics_workspace_aks_name"></a> [azurerm\_log\_analytics\_workspace\_aks\_name](#input\_azurerm\_log\_analytics\_workspace\_aks\_name) | Optional explicit name of the log analytics workspace | `string` | `""` | no |
| <a name="input_azurerm_public_ip_prefix_prefix4_name"></a> [azurerm\_public\_ip\_prefix\_prefix4\_name](#input\_azurerm\_public\_ip\_prefix\_prefix4\_name) | Optional explicit name of the public ipv4 prefix | `string` | `""` | no |
| <a name="input_azurerm_public_ip_prefix_prefix6_name"></a> [azurerm\_public\_ip\_prefix\_prefix6\_name](#input\_azurerm\_public\_ip\_prefix\_prefix6\_name) | Optional explicit name of the public ipv6 prefix | `string` | `""` | no |
| <a name="input_azurerm_resource_group_aks_name"></a> [azurerm\_resource\_group\_aks\_name](#input\_azurerm\_resource\_group\_aks\_name) | Optional explicit name of the AKS resource group | `string` | `""` | no |
| <a name="input_azurerm_resource_group_dis_name"></a> [azurerm\_resource\_group\_dis\_name](#input\_azurerm\_resource\_group\_dis\_name) | Optional explicit name of the DIS resource group | `string` | `""` | no |
| <a name="input_azurerm_resource_group_monitor_name"></a> [azurerm\_resource\_group\_monitor\_name](#input\_azurerm\_resource\_group\_monitor\_name) | Optional explicit name of the monitor resource group | `string` | `""` | no |
| <a name="input_azurerm_storage_account_aks_name"></a> [azurerm\_storage\_account\_aks\_name](#input\_azurerm\_storage\_account\_aks\_name) | Optional explicit name of the AKS Log storage account (must be 3-24 characters, lowercase alphanumeric only) | `string` | `""` | no |
| <a name="input_azurerm_virtual_network_aks_name"></a> [azurerm\_virtual\_network\_aks\_name](#input\_azurerm\_virtual\_network\_aks\_name) | Optional explicit name of the AKS virtual network | `string` | `""` | no |
| <a name="input_azurerm_virtual_public_ip_pip4_name"></a> [azurerm\_virtual\_public\_ip\_pip4\_name](#input\_azurerm\_virtual\_public\_ip\_pip4\_name) | Optional explicit name of the public ipv4 | `string` | `""` | no |
| <a name="input_azurerm_virtual_public_ip_pip6_name"></a> [azurerm\_virtual\_public\_ip\_pip6\_name](#input\_azurerm\_virtual\_public\_ip\_pip6\_name) | Optional explicit name of the public ipv6 | `string` | `""` | no |
| <a name="input_enable_keda"></a> [enable\_keda](#input\_enable\_keda) | Enable KEDA (Kubernetes Event-driven Autoscaling) for workload autoscaling | `bool` | `false` | no |
| <a name="input_enable_multi_tenancy"></a> [enable\_multi\_tenancy](#input\_enable\_multi\_tenancy) | Enable multi tenancy in the cluster | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for resources (required, max 4 characters). Combined with prefix, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Default region for resources | `string` | `"norwayeast"` | no |
| <a name="input_node_pool_configs"></a> [node\_pool\_configs](#input\_node\_pool\_configs) | Configuration for additional node pools. Each key becomes the node pool name (max 12 chars, lowercase alphanumeric). Set ephemeral\_os\_disk=true for VMs with sufficient cache/NVMe storage. When auto\_scaling\_enabled=true, node\_count is optional (initial count), and min\_count/max\_count are required. When auto\_scaling\_enabled=false, node\_count is required. | <pre>map(object({<br/>    vm_size              = string<br/>    auto_scaling_enabled = bool<br/>    node_count           = optional(number)<br/>    min_count            = optional(number)<br/>    max_count            = optional(number)<br/>    os_sku               = optional(string, "AzureLinux")<br/>    max_pods             = optional(number, 200)<br/>    zones                = optional(list(string), ["1", "2", "3"])<br/>    node_labels          = optional(map(string), {})<br/>    node_taints          = optional(list(string), [])<br/>    ephemeral_os_disk    = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_node_pool_subnet_prefixes"></a> [node\_pool\_subnet\_prefixes](#input\_node\_pool\_subnet\_prefixes) | Map of node pool names to their subnet address prefixes. Keys must match node\_pool\_configs keys. | `map(list(string))` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names (required, max 8 characters). Combined with environment, must not exceed 12 characters for storage account naming. | `string` | n/a | yes |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | List of service endpoints to associate with the AKS subnets | `list(string)` | `[]` | no |
| <a name="input_system_pool_config"></a> [system\_pool\_config](#input\_system\_pool\_config) | Configuration for the system node pool. Set ephemeral\_os\_disk=true for VMs with sufficient cache/NVMe storage. When auto\_scaling\_enabled=true, node\_count is optional (initial count), and min\_count/max\_count are required. When auto\_scaling\_enabled=false, node\_count is required. | <pre>object({<br/>    vm_size              = string<br/>    auto_scaling_enabled = bool<br/>    node_count           = optional(number)<br/>    min_count            = optional(number)<br/>    max_count            = optional(number)<br/>    ephemeral_os_disk    = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_system_pool_subnet_prefixes"></a> [system\_pool\_subnet\_prefixes](#input\_system\_pool\_subnet\_prefixes) | Address prefixes for the system pool subnet (IPv4 and IPv6) | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | VNet address space | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_identity"></a> [aks\_identity](#output\_aks\_identity) | Managed Service Identity that is configured on this Kubernetes Cluster |
| <a name="output_aks_kubelet_identity"></a> [aks\_kubelet\_identity](#output\_aks\_kubelet\_identity) | Managed Identity assigned to the Kubelets |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The name of the managed Kubernetes Cluster |
| <a name="output_aks_node_resource_group"></a> [aks\_node\_resource\_group](#output\_aks\_node\_resource\_group) | The name of the Resource Group in which the managed Kubernetes Cluster exists |
| <a name="output_aks_oidc_issuer_url"></a> [aks\_oidc\_issuer\_url](#output\_aks\_oidc\_issuer\_url) | The OIDC issuer URL that is associated with the cluster |
| <a name="output_aks_workpool_vnet_id"></a> [aks\_workpool\_vnet\_id](#output\_aks\_workpool\_vnet\_id) | ID of the vnets where the workpool nodes are located |
| <a name="output_aks_workpool_vnet_name"></a> [aks\_workpool\_vnet\_name](#output\_aks\_workpool\_vnet\_name) | Name of the vnets where the workpool nodes are located |
| <a name="output_aks_workpool_vnet_resource_group_name"></a> [aks\_workpool\_vnet\_resource\_group\_name](#output\_aks\_workpool\_vnet\_resource\_group\_name) | Name of the resource group where the aks vnet is deployed |
| <a name="output_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#output\_azurerm\_kubernetes\_cluster\_id) | Resource id of aks cluster |
| <a name="output_dis_resource_group_id"></a> [dis\_resource\_group\_id](#output\_dis\_resource\_group\_id) | ID of the resource group where the DIS operators creates their resources |
| <a name="output_dis_resource_group_name"></a> [dis\_resource\_group\_name](#output\_dis\_resource\_group\_name) | Name of the resource group where the DIS operators creates their resources |
| <a name="output_kube_admin_config"></a> [kube\_admin\_config](#output\_kube\_admin\_config) | Base64 encoded cert/key/user/pass used by clients to authenticate to the Kubernetes cluster |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Base64 encoded Kubernetes configuration for accessing the cluster |
| <a name="output_pip4_ip_address"></a> [pip4\_ip\_address](#output\_pip4\_ip\_address) | The IPv4 address value that was allocated |
| <a name="output_pip6_ip_address"></a> [pip6\_ip\_address](#output\_pip6\_ip\_address) | The IPv6 address value that was allocated |
