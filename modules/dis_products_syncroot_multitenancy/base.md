# dis_products_syncroot_multitenancy

Deploys a Flux OCI repository configuration for GitOps-based product syncroot deployment in a multi-tenant AKS cluster.

The `product` name determines the Kubernetes namespace, Flux configuration, and RBAC scopes.
By default, the OCI URL is `oci://altinncr.azurecr.io/<product>/syncroot`. Set the optional
`syncroot_name` when the registry prefix differs: `product = "access-management"` and
`syncroot_name = "accessmanagement"` use namespace `product-access-management` with
`oci://altinncr.azurecr.io/accessmanagement/syncroot`. Environment tags and paths are unchanged.

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
  syncroot_name   = var.syncroot_name

  # Flux postBuild variable substitution
  substitute = {
    DATABASE_URL = "jdbc:sqlserver://myapp-prod-server.database.windows.net;databaseName=mydb"
    API_KEY      = var.api_key
  }
}
```
