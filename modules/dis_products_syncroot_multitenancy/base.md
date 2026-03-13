# dis_products_syncroot_multitenancy

Deploys a Flux OCI repository configuration for GitOps-based product syncroot deployment in a multi-tenant AKS cluster.

## Usage

```hcl
module "dis_products_syncroot_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_products_syncroot_multitenancy?ref=<version>"

  product        = var.product_name
  environment    = var.environment
  aks_cluster_id = module.aks.cluster_id
  admin_group_id = var.admin_group_id
  reader_group_id = var.reader_group_id
}
```
