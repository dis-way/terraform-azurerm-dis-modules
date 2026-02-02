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
| [azapi_resource.external_secrets_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno_policies](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.lets_encrypt_tls_issuer](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.linkerd](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#input\_azurerm\_kubernetes\_cluster\_id) | AKS cluster resource id | `string` | n/a | yes |
| <a name="input_enable_lets_encrypt_tls_issuer"></a> [enable\_lets\_encrypt\_tls\_issuer](#input\_enable\_lets\_encrypt\_tls\_issuer) | Enable Let's Encrypt cert-manager issuer for TLS certificates | `bool` | `true` | no |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | OCI image that Flux should watch and reconcile | `string` | n/a | yes |
| <a name="input_linkerd_default_inbound_policy"></a> [linkerd\_default\_inbound\_policy](#input\_linkerd\_default\_inbound\_policy) | Default inbound policy for Linkerd | `string` | `"deny"` | no |
| <a name="input_linkerd_disable_ipv6"></a> [linkerd\_disable\_ipv6](#input\_linkerd\_disable\_ipv6) | Disable IPv6 for Linkerd | `string` | `"false"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription id where aks cluster and other resources are deployed | `string` | n/a | yes |
| <a name="input_tls_lets_encrypt_workload_identity_client_id"></a> [tls\_lets\_encrypt\_workload\_identity\_client\_id](#input\_tls\_lets\_encrypt\_workload\_identity\_client\_id) | Client id for cert-manager workload identity (Let's Encrypt DNS issuer) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_name"></a> [tls\_lets\_encrypt\_zone\_name](#input\_tls\_lets\_encrypt\_zone\_name) | Azure DNS zone name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_rg_name"></a> [tls\_lets\_encrypt\_zone\_rg\_name](#input\_tls\_lets\_encrypt\_zone\_rg\_name) | Azure DNS zone resource group name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
