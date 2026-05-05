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
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_federated_identity_credential.dispgsql_fic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.dispgsql_network_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.postgresql_subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.dispgsql_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peered_vnet_to_postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.postgresql_to_peered_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for resources | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location where the PostgreSQL vnets and subnets are deployed | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the PostgreSQL vnet and subnets | `string` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | Oidc issuer url needed for federation | `string` | n/a | yes |
| <a name="input_peered_vnets"></a> [peered\_vnets](#input\_peered\_vnets) | ID of the vnet this Vnet should be peered with | <pre>object({<br/>    name                = string<br/>    id                  = string<br/>    resource_group_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resources group where the PostgreSQL vnets and subnets are placed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Set of tags to add to vnet | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | Optional override for the user-assigned identity name used by dis-pgsql. | `string` | `""` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | IPv4 address space of the PostgreSQL vnet, must be a valid CIDR notation of size /23 or /24 | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dispgsql_uami_client_id"></a> [dispgsql\_uami\_client\_id](#output\_dispgsql\_uami\_client\_id) | The client ID of the user assigned managed identity for dis-pgsql. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The IDs of the created subnets. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the created virtual network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the created virtual network. |
