# dis_products_cluster_access_multitenancy

Grants product groups cluster-scoped access in a multi-tenant AKS cluster: AKS RBAC Reader for admin groups, and the Cluster User Role (fetch kubeconfig) for admin and reader groups.

Azure allows only one role assignment per group, role and scope, so these assignments are created once per distinct group rather than per product. Products can share groups, and a group's cluster access goes away only when no product uses it anymore. Namespace-scoped access stays with each product in [dis_products_syncroot_multitenancy](../dis_products_syncroot_multitenancy).

## Usage

```hcl
locals {
  # Every product_* module on the cluster
  products = [module.product_core, module.product_profile]
}

module "product_cluster_access" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_products_cluster_access_multitenancy?ref=<version>"

  aks_cluster_id   = module.aks.cluster_id
  admin_group_ids  = toset([for p in local.products : p.admin_group_id])
  reader_group_ids = toset([for p in local.products : p.reader_group_id])
}
```
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.cluster_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_group_ids"></a> [admin\_group\_ids](#input\_admin\_group\_ids) | Object ids of the product admin groups. Each gets AKS RBAC Reader on the cluster and the Cluster User Role. | `set(string)` | n/a | yes |
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | The ID of the AKS cluster the groups get access to | `string` | n/a | yes |
| <a name="input_reader_group_ids"></a> [reader\_group\_ids](#input\_reader\_group\_ids) | Object ids of the product reader groups. Each gets the Cluster User Role. | `set(string)` | n/a | yes |
