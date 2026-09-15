# dis_system_kv

Creates a dedicated Key Vault for platform/system secrets used by an AKS workload, configures a federated user-assigned identity for the cluster service account, grants the required RBAC access, and seeds the vault with a map of secret values.

## Usage

```hcl
module "dis_system_kv" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_system_kv?ref=<version>"

  prefix                                     = var.team_name
  environment                                = var.environment
  resource_group_name                        = azurerm_resource_group.dis_system.name
  tenant_id                                  = var.tenant_id
  azurerm_kubernetes_cluster_oidc_issuer_url = module.aks.oidc_issuer_url
  ci_service_principal_object_id             = data.azurerm_client_config.current.object_id
  tags                                       = local.tags

  secrets = {
    "tenant-id" = var.tenant_id
    "aks-name"  = module.aks.name
  }
}
```
