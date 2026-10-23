# dis_products_syncroot_multitenancy

Deploys a Flux OCI repository configuration for GitOps-based product syncroot deployment in a multi-tenant AKS cluster.

The admin group gets AKS RBAC Admin and the reader group AKS RBAC Reader on the `product-<product>` namespace. Cluster-scoped access (RBAC Reader for admin groups, Cluster User Role for both) is granted once per group by [dis_products_cluster_access_multitenancy](../dis_products_cluster_access_multitenancy), so several products can share groups. Pass it this module's `admin_group_id` and `reader_group_id` outputs.

## Usage

### Minimal usage example
```hcl
module "dis_products_syncroot_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_products_syncroot_multitenancy?ref=<version>"

  product         = var.product_name
  environment     = var.environment
  aks_cluster_id  = module.aks.cluster_id
  admin_group_id  = var.admin_group_id
  reader_group_id = var.reader_group_id
}
```

### Full usage example (with optional parameters)
```hcl
module "dis_products_syncroot_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_products_syncroot_multitenancy?ref=<version>"

  product         = var.product_name
  environment     = var.environment
  aks_cluster_id  = module.aks.cluster_id
  admin_group_id  = var.admin_group_id
  reader_group_id = var.reader_group_id
  prune_enabled   = true

  # Flux postBuild variable substitution
  substitute = {
    DATABASE_URL = "jdbc:sqlserver://myapp-prod-server.database.windows.net;databaseName=mydb"
    API_KEY      = var.api_key
  }
}
```
