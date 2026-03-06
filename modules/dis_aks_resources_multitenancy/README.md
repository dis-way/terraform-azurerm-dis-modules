# dis_aks_resources_multitenancy

Deploys multitenancy platform services onto an AKS cluster: cert-manager, Kyverno, External Secrets Operator, Linkerd, OpenTelemetry, DIS identity operator, and optionally OpenCost and the DIS PostgreSQL operator.

## Usage

```hcl
module "dis_aks_resources_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_aks_resources_multitenancy?ref=<version>"

  azurerm_kubernetes_cluster_id        = module.aks.cluster_id
  azurerm_kubernetes_cluster_oidc_issuer_url = module.aks.oidc_issuer_url
  subscription_id                      = var.subscription_id

  aks_node_resource_group  = module.aks.node_resource_group
  aks_vnet_ipv4_cidr       = var.aks_vnet_ipv4_cidr
  aks_vnet_ipv6_cidr       = var.aks_vnet_ipv6_cidr
  aks_public_ipv4_address  = module.aks.pip4_ip_address
  aks_public_ipv6_address  = module.aks.pip6_ip_address
  default_gateway_hostname = var.default_gateway_hostname

  flux_release_tag = var.flux_release_tag

  azurerm_dis_identity_resource_group_id = var.dis_identity_resource_group_id
  dis_identity_target_tenant_id          = var.tenant_id

  otel_amw_write_endpoint = module.dis_monitoring_resources.amw_write_endpoint
  otel_client_id          = module.dis_monitoring_resources.otel_client_id
  otel_kv_uri             = module.dis_monitoring_resources.kv_uri
  otel_tenant_id          = var.tenant_id
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
| [azapi_resource.cert_manager](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_identity_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_pgsql_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.external_secrets_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno_policies](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.lets_encrypt_tls_issuer](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.linkerd](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.opencost](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_collector](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.traefik](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_federated_identity_credential.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_node_resource_group"></a> [aks\_node\_resource\_group](#input\_aks\_node\_resource\_group) | AKS node resource group | `string` | n/a | yes |
| <a name="input_aks_public_ipv4_address"></a> [aks\_public\_ipv4\_address](#input\_aks\_public\_ipv4\_address) | The public IPv4 address of the AKS cluster | `string` | n/a | yes |
| <a name="input_aks_public_ipv6_address"></a> [aks\_public\_ipv6\_address](#input\_aks\_public\_ipv6\_address) | The public IPv6 address of the AKS cluster | `string` | n/a | yes |
| <a name="input_aks_resource_group"></a> [aks\_resource\_group](#input\_aks\_resource\_group) | AKS resource group name. | `string` | `""` | no |
| <a name="input_aks_vnet_ipv4_cidr"></a> [aks\_vnet\_ipv4\_cidr](#input\_aks\_vnet\_ipv4\_cidr) | AKS VNet IPv4 CIDR | `string` | n/a | yes |
| <a name="input_aks_vnet_ipv6_cidr"></a> [aks\_vnet\_ipv6\_cidr](#input\_aks\_vnet\_ipv6\_cidr) | AKS VNet IPv6 CIDR | `string` | n/a | yes |
| <a name="input_aks_workpool_vnet_name"></a> [aks\_workpool\_vnet\_name](#input\_aks\_workpool\_vnet\_name) | Name of the AKS workpool VNet. | `string` | `""` | no |
| <a name="input_azurerm_dis_identity_resource_group_id"></a> [azurerm\_dis\_identity\_resource\_group\_id](#input\_azurerm\_dis\_identity\_resource\_group\_id) | The resource group ID where the User Assigned Managed Identity managed by dis-identity-operator will be created. | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#input\_azurerm\_kubernetes\_cluster\_id) | AKS cluster resource id | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. | `string` | n/a | yes |
| <a name="input_default_gateway_hostname"></a> [default\_gateway\_hostname](#input\_default\_gateway\_hostname) | The default gateway hostname of the AKS cluster. This will be the Hostname in the default gateway https://gateway-api.sigs.k8s.io/reference/spec/#hostname | `string` | n/a | yes |
| <a name="input_dis_db_vnet_name"></a> [dis\_db\_vnet\_name](#input\_dis\_db\_vnet\_name) | Name of the VNet hosting DIS database resources. | `string` | `""` | no |
| <a name="input_dis_identity_target_tenant_id"></a> [dis\_identity\_target\_tenant\_id](#input\_dis\_identity\_target\_tenant\_id) | Tenant ID where dis-identity ApplicationIdentity will be created | `string` | n/a | yes |
| <a name="input_dis_pgsql_uami_client_id"></a> [dis\_pgsql\_uami\_client\_id](#input\_dis\_pgsql\_uami\_client\_id) | Client id for the dis-pgsql workload identity. | `string` | `""` | no |
| <a name="input_dis_resource_group_name"></a> [dis\_resource\_group\_name](#input\_dis\_resource\_group\_name) | Name of the resource group where DIS operators create their resources. | `string` | `""` | no |
| <a name="input_enable_dis_pgsql_operator"></a> [enable\_dis\_pgsql\_operator](#input\_enable\_dis\_pgsql\_operator) | Enable the dis-pgsql operator in the cluster. | `bool` | `false` | no |
| <a name="input_enable_lets_encrypt_tls_issuer"></a> [enable\_lets\_encrypt\_tls\_issuer](#input\_enable\_lets\_encrypt\_tls\_issuer) | Enable Let's Encrypt cert-manager issuer for TLS certificates | `bool` | `true` | no |
| <a name="input_enable_opencost"></a> [enable\_opencost](#input\_enable\_opencost) | Enable opencost | `bool` | `false` | no |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | OCI image that Flux should watch and reconcile | `string` | n/a | yes |
| <a name="input_linkerd_default_inbound_policy"></a> [linkerd\_default\_inbound\_policy](#input\_linkerd\_default\_inbound\_policy) | Default inbound policy for Linkerd | `string` | `"deny"` | no |
| <a name="input_linkerd_disable_ipv6"></a> [linkerd\_disable\_ipv6](#input\_linkerd\_disable\_ipv6) | Disable IPv6 for Linkerd | `string` | `"false"` | no |
| <a name="input_obs_tenant_id"></a> [obs\_tenant\_id](#input\_obs\_tenant\_id) | Tenant id for the observability app. | `string` | `""` | no |
| <a name="input_opencost_azure_monitoring_workspace_id"></a> [opencost\_azure\_monitoring\_workspace\_id](#input\_opencost\_azure\_monitoring\_workspace\_id) | Azure id of the monitoring workspace to read from | `string` | `""` | no |
| <a name="input_opencost_prometheus_endpoint"></a> [opencost\_prometheus\_endpoint](#input\_opencost\_prometheus\_endpoint) | URL of the prometheus endpint that opencost queries | `string` | `""` | no |
| <a name="input_opencost_tenant_id"></a> [opencost\_tenant\_id](#input\_opencost\_tenant\_id) | Tenant id where the azure monitoring workspace is deployed | `string` | `""` | no |
| <a name="input_otel_amw_write_endpoint"></a> [otel\_amw\_write\_endpoint](#input\_otel\_amw\_write\_endpoint) | Azure Monitor Workspaces write endpoint to write prometheus metrics to via prometheus exporter | `string` | n/a | yes |
| <a name="input_otel_client_id"></a> [otel\_client\_id](#input\_otel\_client\_id) | Client id for the federated identity used by otel | `string` | n/a | yes |
| <a name="input_otel_kv_uri"></a> [otel\_kv\_uri](#input\_otel\_kv\_uri) | Key vault uri for otel config | `string` | n/a | yes |
| <a name="input_otel_tenant_id"></a> [otel\_tenant\_id](#input\_otel\_tenant\_id) | Tenant id for the obs app | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription id where aks cluster and other resources are deployed | `string` | n/a | yes |
| <a name="input_tls_lets_encrypt_workload_identity_client_id"></a> [tls\_lets\_encrypt\_workload\_identity\_client\_id](#input\_tls\_lets\_encrypt\_workload\_identity\_client\_id) | Client id for cert-manager workload identity (Let's Encrypt DNS issuer) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_name"></a> [tls\_lets\_encrypt\_zone\_name](#input\_tls\_lets\_encrypt\_zone\_name) | Azure DNS zone name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_rg_name"></a> [tls\_lets\_encrypt\_zone\_rg\_name](#input\_tls\_lets\_encrypt\_zone\_rg\_name) | Azure DNS zone resource group name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
