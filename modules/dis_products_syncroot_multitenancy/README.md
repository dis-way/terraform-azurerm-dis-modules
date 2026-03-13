# dis_products_syncroot_multitenancy

Deploys a Flux OCI repository configuration for GitOps-based product syncroot deployment in a multi-tenant AKS cluster.

## Usage

```hcl
module "dis_products_syncroot_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_products_syncroot_multitenancy?ref=<version>"

  product        = var.product_name
  environment    = var.environment
  aks_cluster_id = module.aks.cluster_id
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.1 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.syncroot](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_role_assignment.cluster_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.namespace_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.namespace_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random_postfix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_id"></a> [admin\_group\_id](#input\_admin\_group\_id) | Object id of the EntraID group that should have admin on the product namespace and reader in the cluster | `string` | n/a | yes |
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | The ID of the AKS cluster where the Flux configuration will be applied | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Name of the product | `string` | n/a | yes |
| <a name="input_prune_enabled"></a> [prune\_enabled](#input\_prune\_enabled) | Control if the syncroot enables prune of resources | `bool` | `false` | no |
| <a name="input_reader_group_id"></a> [reader\_group\_id](#input\_reader\_group\_id) | Object id of the EntraID group that should have reader permissions in the product namespace | `string` | n/a | yes |
