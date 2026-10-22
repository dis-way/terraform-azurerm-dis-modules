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
