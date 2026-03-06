### Minimal usage example
This module provisions a dedicated PostgreSQL VNet, creates 16 delegated PostgreSQL Flexible Server subnets, peers it with an existing VNet, and creates a user-assigned identity + federated credential for `dis-pgsql` workload identity.

```hcl
module "dis_pgsql_multitenancy" {
  source = "./modules/dis_pgsql_multitenancy"

  resource_group_name = "rg-dis-dev"
  location            = "norwayeast"
  name                = "dis-pgsql-dev"
  environment         = "dev"
  oidc_issuer_url     = module.aks.aks_oidc_issuer_url
  vnet_address_space  = "10.100.10.0/24"

  peered_vnets = {
    id                  = module.aks.aks_workpool_vnet_id
    name                = module.aks.aks_workpool_vnet_name
    resource_group_name = module.aks.aks_workpool_vnet_resource_group_name
  }

  tags = {
    environment = "dev"
    component   = "dis-pgsql"
  }
}
```
