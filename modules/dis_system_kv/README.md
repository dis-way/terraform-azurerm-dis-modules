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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5 |

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.dis_sync_fic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault.dis_system_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.ci_kv_secrets_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.dis_system_kv_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.dis_sync_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.dis_sys_kv_postfix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. | `string` | n/a | yes |
| <a name="input_ci_service_principal_object_id"></a> [ci\_service\_principal\_object\_id](#input\_ci\_service\_principal\_object\_id) | Object ID of the CI service principal used for role assignments. | `string` | n/a | yes |
| <a name="input_dis_system_kv_namespace"></a> [dis\_system\_kv\_namespace](#input\_dis\_system\_kv\_namespace) | Name of the namespace where dis-system kv sync components are deployed | `string` | `"platform-system"` | no |
| <a name="input_dis_system_kv_service_account_name"></a> [dis\_system\_kv\_service\_account\_name](#input\_dis\_system\_kv\_service\_account\_name) | Name of service account used to sync configs from dis-system key vault | `string` | `"dis-secret-sync-sa"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the dis-system-kv is being created. | `string` | n/a | yes |
| <a name="input_key_vault_name_random_suffix_length"></a> [key\_vault\_name\_random\_suffix\_length](#input\_key\_vault\_name\_random\_suffix\_length) | Number of random characters appended to the Key Vault name to keep it globally unique. | `number` | `6` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be created. | `string` | `"norwayeast"` | no |
| <a name="input_override_user_assigned_identity_name"></a> [override\_user\_assigned\_identity\_name](#input\_override\_user\_assigned\_identity\_name) | Override the default name of the User Assigned Managed Identity. | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix to be used for naming resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the resources are deployed. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to create in the dis-system Key Vault, keyed by Key Vault secret name. The whole map is sensitive, so no value appears in plan output. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources created. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id where everything is deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dis_system_kv_reader_client_id"></a> [dis\_system\_kv\_reader\_client\_id](#output\_dis\_system\_kv\_reader\_client\_id) | n/a |
| <a name="output_dis_system_kv_uri"></a> [dis\_system\_kv\_uri](#output\_dis\_system\_kv\_uri) | n/a |
