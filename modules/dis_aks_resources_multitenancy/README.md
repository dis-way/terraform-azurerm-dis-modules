## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.3.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.cert_manager](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_identity_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.external_secrets_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno_policies](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.lets_encrypt_tls_issuer](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.linkerd](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_collector](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.traefik](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_node_resource_group"></a> [aks\_node\_resource\_group](#input\_aks\_node\_resource\_group) | AKS node resource group | `string` | n/a | yes |
| <a name="input_aks_public_ipv4_address"></a> [aks\_public\_ipv4\_address](#input\_aks\_public\_ipv4\_address) | The public IPv4 address of the AKS cluster | `string` | n/a | yes |
| <a name="input_aks_public_ipv6_address"></a> [aks\_public\_ipv6\_address](#input\_aks\_public\_ipv6\_address) | The public IPv6 address of the AKS cluster | `string` | n/a | yes |
| <a name="input_aks_vnet_ipv4_cidr"></a> [aks\_vnet\_ipv4\_cidr](#input\_aks\_vnet\_ipv4\_cidr) | AKS VNet IPv4 CIDR | `string` | n/a | yes |
| <a name="input_aks_vnet_ipv6_cidr"></a> [aks\_vnet\_ipv6\_cidr](#input\_aks\_vnet\_ipv6\_cidr) | AKS VNet IPv6 CIDR | `string` | n/a | yes |
| <a name="input_azurerm_dis_identity_resource_group_id"></a> [azurerm\_dis\_identity\_resource\_group\_id](#input\_azurerm\_dis\_identity\_resource\_group\_id) | The resource group ID where the User Assigned Managed Identity managed by dis-identity-operator will be created. | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#input\_azurerm\_kubernetes\_cluster\_id) | AKS cluster resource id | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. | `string` | n/a | yes |
| <a name="input_default_gateway_hostname"></a> [default\_gateway\_hostname](#input\_default\_gateway\_hostname) | The default gateway hostname of the AKS cluster. This will be the Hostname in the default gateway https://gateway-api.sigs.k8s.io/reference/spec/#hostname | `string` | n/a | yes |
| <a name="input_dis_identity_target_namespace"></a> [dis\_identity\_target\_namespace](#input\_dis\_identity\_target\_namespace) | Namespace where the dis-identity operator deployment will be created. | `string` | `"flux-system"` | no |
| <a name="input_enable_lets_encrypt_tls_issuer"></a> [enable\_lets\_encrypt\_tls\_issuer](#input\_enable\_lets\_encrypt\_tls\_issuer) | Enable Let's Encrypt cert-manager issuer for TLS certificates | `bool` | `true` | no |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | OCI image that Flux should watch and reconcile | `string` | n/a | yes |
| <a name="input_linkerd_default_inbound_policy"></a> [linkerd\_default\_inbound\_policy](#input\_linkerd\_default\_inbound\_policy) | Default inbound policy for Linkerd | `string` | `"deny"` | no |
| <a name="input_linkerd_disable_ipv6"></a> [linkerd\_disable\_ipv6](#input\_linkerd\_disable\_ipv6) | Disable IPv6 for Linkerd | `string` | `"false"` | no |
| <a name="input_otel_amw_write_endpoint"></a> [otel\_amw\_write\_endpoint](#input\_otel\_amw\_write\_endpoint) | Azure Monitor Workspaces write endpoint to write prometheus metrics to via prometheus exporter | `string` | n/a | yes |
| <a name="input_otel_client_id"></a> [otel\_client\_id](#input\_otel\_client\_id) | Client id for the federated identity used by otel | `string` | n/a | yes |
| <a name="input_otel_kv_uri"></a> [otel\_kv\_uri](#input\_otel\_kv\_uri) | Key vault uri for otel config | `string` | n/a | yes |
| <a name="input_otel_tenant_id"></a> [otel\_tenant\_id](#input\_otel\_tenant\_id) | Tenant id for the obs app | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription id where aks cluster and other resources are deployed | `string` | n/a | yes |
| <a name="input_tls_lets_encrypt_workload_identity_client_id"></a> [tls\_lets\_encrypt\_workload\_identity\_client\_id](#input\_tls\_lets\_encrypt\_workload\_identity\_client\_id) | Client id for cert-manager workload identity (Let's Encrypt DNS issuer) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_name"></a> [tls\_lets\_encrypt\_zone\_name](#input\_tls\_lets\_encrypt\_zone\_name) | Azure DNS zone name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_rg_name"></a> [tls\_lets\_encrypt\_zone\_rg\_name](#input\_tls\_lets\_encrypt\_zone\_rg\_name) | Azure DNS zone resource group name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
