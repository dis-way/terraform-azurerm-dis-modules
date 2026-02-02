### Minimal usage example
This module provisions an Azure DNS child zone (including A/AAAA wildcard records and a Let’s Encrypt CAA record), creates the NS delegation record in the parent zone, and creates an Entra ID application/service principal for `cert-manager` using federated workload identity and grants it `DNS Zone Contributor` on the child zone.

```hcl
module "dis_dns_child_zone_multitenancy" {
  source = "./modules/dis_dns_child_zone_multitenancy"

  # Required identifiers
  prefix      = "myapp"
  environment = "dev"

  # Cluster ingress IPs (used for @ and * records)
  cluster_ipv4_address = "203.0.113.10"
  cluster_ipv6_address = "2001:db8::10"

  # Needed for federated workload identity for cert-manager
  oidc_issuer_url = module.aks.aks_oidc_issuer_url

  # Optional
  location             = "norwayeast"
  parent_dns_zone_name = "altinn.cloud"
  parent_dns_zone_rg   = "DNS"
  # child_dns_zone_rg_name = "custom-rg-name"
  # child_dns_zone_name    = "dev.myapp.altinn.cloud"

  providers = {
    azurerm             = azurerm
    azurerm.parent_zone = azurerm.parent_zone
    azuread             = azuread
  }
}
```
