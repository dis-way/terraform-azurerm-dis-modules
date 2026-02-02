### Minimal usage example
This module provisions a workload identity (user-assigned managed identity + federated credential) and deploys the DIS APIM operator to an AKS cluster via an AKS Flux configuration (OCI source).

```hcl
module "dis_apim_operator_multitenancy" {
  source = "./modules/dis_apim_operator_multitenancy"

  # AKS
  kubernetes_cluster_id              = module.aks.azurerm_kubernetes_cluster_id
  kubernetes_cluster_oidc_issuer_url = module.aks.aks_oidc_issuer_url
  kubernetes_node_resource_group     = module.aks.aks_node_resource_group
  kubernetes_node_location           = "norwayeast"

  # APIM
  apim_id                 = azurerm_api_management.apim.id
  apim_subscription_id     = data.azurerm_client_config.current.subscription_id
  apim_resource_group_name = azurerm_api_management.apim.resource_group_name
  apim_service_name        = azurerm_api_management.apim.name
  default_logger_name      = "apim-default-logger"

  # Operator settings
  target_namespace = "platform-system"
  # namespace_suffix = "-tenant" # Optional: restrict reconciliation to namespaces ending with this suffix

  # Optional
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
| [azapi_resource.dis_apim_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_federated_identity_credential.disapim_fic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.disapim_service_operator_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.disapim_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apim_id"></a> [apim\_id](#input\_apim\_id) | APIM resource id | `string` | n/a | yes |
| <a name="input_apim_resource_group_name"></a> [apim\_resource\_group\_name](#input\_apim\_resource\_group\_name) | Resource group where the APIM service is located | `string` | n/a | yes |
| <a name="input_apim_service_name"></a> [apim\_service\_name](#input\_apim\_service\_name) | APIM service name | `string` | n/a | yes |
| <a name="input_apim_subscription_id"></a> [apim\_subscription\_id](#input\_apim\_subscription\_id) | Subscription id where the APIM service is located | `string` | n/a | yes |
| <a name="input_default_logger_name"></a> [default\_logger\_name](#input\_default_logger\_name) | Name of the logger in the APIM service that will be used as default for APIs | `string` | n/a | yes |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | Flux release tag | `string` | `"latest"` | no |
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | AKS cluster resource id | `string` | n/a | yes |
| <a name="input_kubernetes_cluster_oidc_issuer_url"></a> [kubernetes\_cluster\_oidc\_issuer\_url](#input\_kubernetes\_cluster\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. | `string` | n/a | yes |
| <a name="input_kubernetes_node_location"></a> [kubernetes\_node\_location](#input\_kubernetes\_node\_location) | AKS node location | `string` | n/a | yes |
| <a name="input_kubernetes_node_resource_group"></a> [kubernetes\_node\_resource\_group](#input\_kubernetes\_node\_resource\_group) | AKS node resource group name | `string` | n/a | yes |
| <a name="input_namespace_suffix"></a> [namespace\_suffix](#input\_namespace\_suffix) | Suffix of namespaces that the operator will reconcile APIM objects in. No suffix watches all namespaces. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Azure Service Operators User Assigned Managed Identity. | `map(string)` | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where the operator deployment will be created | `string` | n/a | yes |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | User assigned identity name | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dis_apim_workload_identity_client_id"></a> [dis\_apim\_workload\_identity\_client\_id](#output\_dis\_apim\_workload\_identity\_client\_id) | Client ID for the operator workload identity (sensitive). |

