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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_azurerm.parent_zone"></a> [azurerm.parent_zone](#provider\_azurerm\.parent_zone) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.cert_manager_app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.cert_manager_fed_identity](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.cert_manager_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_dns_a_record.base_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_a_record.wildcard_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_aaaa_record.base_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_aaaa_record) | resource |
| [azurerm_dns_aaaa_record.wildcard_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_aaaa_record) | resource |
| [azurerm_dns_caa_record.issue_lets_encrypt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_ns_record.child_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ns_record) | resource |
| [azurerm_dns_zone.child_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_resource_group.dns_child_zone_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.dns_zone_contributor_cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_child_dns_zone_name"></a> [child\_dns\_zone\_name](#input\_child\_dns\_zone\_name) | Child zone name | `string` | `""` | no |
| <a name="input_child_dns_zone_rg_name"></a> [child\_dns\_zone\_rg\_name](#input\_child\_dns\_zone\_rg\_name) | Override generated name for resource group for child dns zone. | `string` | `""` | no |
| <a name="input_cluster_ipv4_address"></a> [cluster\_ipv4\_address](#input\_cluster\_ipv4\_address) | Cluster ipv4 address | `string` | n/a | yes |
| <a name="input_cluster_ipv6_address"></a> [cluster\_ipv6\_address](#input\_cluster\_ipv6\_address) | Cluster ipv6 address | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location for resources | `string` | `"norwayeast"` | no |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | Oidc issuer url needed for federation | `string` | n/a | yes |
| <a name="input_parent_dns_zone_name"></a> [parent\_dns\_zone\_name](#input\_parent\_dns\_zone\_name) | Parent zone name | `string` | `"altinn.cloud"` | no |
| <a name="input_parent_dns_zone_rg"></a> [parent\_dns\_zone\_rg](#input\_parent\_dns\_zone\_rg) | Resource group for parent dns zone | `string` | `"DNS"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resources prefixes | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azuread_cert_manager_client_id"></a> [azuread\_cert\_manager\_client\_id](#output\_azuread\_cert\_manager\_client\_id) | Client ID for the Entra ID application used by cert-manager (sensitive). |
| <a name="output_azurerm_dns_zone_name"></a> [azurerm\_dns\_zone\_name](#output\_azurerm\_dns\_zone\_name) | The DNS name of the created child zone. |
| <a name="output_azurerm_dns_zone_resource_group_name"></a> [azurerm\_dns\_zone\_resource\_group\_name](#output\_azurerm\_dns\_zone\_resource\_group\_name) | Resource group name containing the created child zone. |
