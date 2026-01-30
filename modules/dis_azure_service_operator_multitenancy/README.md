### Minimal usage example
This module provisions the Azure resources needed for running Azure Service Operator (ASO) in AKS using workload identity, and configures ASO deployment via an AKS Flux configuration (OCI source).

```hcl
module "dis_azure_service_operator" {
  source = "./modules/dis_azure_service_operator"

  # Required identifiers
  prefix      = "myapp"
  environment = "dev"

  # Azure / AKS
  azurerm_subscription_id                  = data.azurerm_client_config.current.subscription_id
  azurerm_kubernetes_cluster_id            = module.aks.azurerm_kubernetes_cluster_id
  azurerm_kubernetes_cluster_oidc_issuer_url = module.aks.aks_oidc_issuer_url
  azurerm_kubernetes_workpool_vnet_id      = module.aks.aks_workpool_vnet_id

  # Resource group where ASO-managed resources should be created
  dis_resource_group_id = module.aks.dis_resource_group_id

  # Optional
  location         = "norwayeast"
  flux_release_tag = "latest"
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.aso](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_federated_identity_credential.aso_fic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_resource_group.aso_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aso_aks_vnet_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aso_contrib_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.user_assigned_identity_role_dis_aks_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.user_assigned_identity_role_dis_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.aso_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aso_crd_pattern"></a> [aso\_crd\_pattern](#input\_aso\_crd\_pattern) | The pattern for the Azure Service Operator Custom Resource Definitions (CRDs). | `string` | `"managedidentity.azure.com/*;authorization.azure.com/*;dbforpostgresql.azure.com/*;network.azure.com/*;insights.azure.com/*"` | no |
| <a name="input_aso_namespace"></a> [aso\_namespace](#input\_aso\_namespace) | The namespace where the Azure Service Operator will be deployed. | `string` | `"azureserviceoperator-system"` | no |
| <a name="input_aso_service_account_name"></a> [aso\_service\_account\_name](#input\_aso\_service\_account\_name) | The name of the service account for the Azure Service Operator. | `string` | `"azureserviceoperator-system"` | no |
| <a name="input_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#input\_azurerm\_kubernetes\_cluster\_id) | The ID of the AKS cluster where the Azure Service Operator will be deployed. | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_workpool_vnet_id"></a> [azurerm\_kubernetes\_workpool\_vnet\_id](#input\_azurerm\_kubernetes\_workpool\_vnet\_id) | The ID of the vnet where the aks workpools nodes are deployed. Needed to grant aso permissions | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_aso_name"></a> [azurerm\_resource\_group\_aso\_name](#input\_azurerm\_resource\_group\_aso\_name) | The name of the Azure Service Operators Resource Group. | `string` | `""` | no |
| <a name="input_azurerm_subscription_id"></a> [azurerm\_subscription\_id](#input\_azurerm\_subscription\_id) | The Azure Subscription ID where the Azure Service Operators User Assigned Managed Identity will be created. | `string` | n/a | yes |
| <a name="input_azurerm_user_assigned_identity_name"></a> [azurerm\_user\_assigned\_identity\_name](#input\_azurerm\_user\_assigned\_identity\_name) | The name of the Azure Service Operators User Assigned Managed Identity. | `string` | `""` | no |
| <a name="input_dis_resource_group_id"></a> [dis\_resource\_group\_id](#input\_dis\_resource\_group\_id) | The resource group ID where the Azure Service Operator resources will be created. | `string` | `""` | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the Azure Service Operators User Assigned Managed Identity is being created. | `string` | n/a | yes |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | The release tag for the Flux configuration. | `string` | `"latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be created. | `string` | `"norwayeast"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix to be used for naming resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Azure Service Operators User Assigned Managed Identity. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_user_assigned_identity_principal_id"></a> [azurerm\_user\_assigned\_identity\_principal\_id](#output\_azurerm\_user\_assigned\_identity\_principal\_id) | The principal ID of the Azure Service Operator User Assigned Managed Identity. |

