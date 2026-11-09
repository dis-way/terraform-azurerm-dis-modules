# dis_aks_resources_multitenancy

Deploys multitenancy platform services onto an AKS cluster: cert-manager, Kyverno, External Secrets Operator, Gateway API CRDs, Linkerd, OpenTelemetry, DIS identity operator, and optionally OpenCost, the DIS PostgreSQL operator, and the DIS Vault operator.

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

  # dis-system Key Vault, read through the dis-system-store SecretStore in platform-system.
  # The dis_system_kv module's defaults (namespace platform-system, service account
  # dis-secret-sync-sa) match the ServiceAccount the ESO multitenancy/post-deploy layer creates.
  tenant_id               = var.tenant_id
  dis_system_kv_client_id = module.dis_system_kv.dis_system_kv_reader_client_id
  dis_system_kv_id        = module.dis_system_kv.dis_system_kv_id
  dis_system_kv_uri       = module.dis_system_kv.dis_system_kv_uri
}
```

## Flux webhook receiver

Set `enable_flux_webhook_receiver = true` to deploy the webhook receiver and select Traefik's `multitenancy-flux-webhook` layer ([RFC 0017](https://github.com/Altinn/altinn-platform/blob/main/rfcs/0017-on-demand-flux-reconcile.md)). It defaults to `false`; disabling it restores the standard Traefik layer and prunes the receiver resources.

Before enabling, release both packages to the `flux_release_tag` ring, set `lb_source_range_dis_edge` and `lb_source_range_dis_edge_ipv6` to the edge cluster's canonical outbound CIDRs (no loopback or `/0`), and provide a non-empty `default_gateway_hostname`. Product receivers using `generic-oidc` require Flux 2.9 or later.

## Central access token

Set `enable_central_accesstoken = true` and `central_accesstoken_kv_uri` to add the `multitenancy/secrets` and `multitenancy/central-accesstoken` layers of external-secrets-operator (oci-external-secrets-operator v1.13.0 or later). The module writes `central_accesstoken_kv_uri` to the dis-system Key Vault as `external-secrets-operator-central-accesstoken-kv-url`; `multitenancy/secrets` copies it into the `external-secrets-operator-vars` Secret, which `multitenancy/central-accesstoken` reads through `postBuild.substituteFrom`. The layers run in the order `multitenancy` → `post-deploy` → `secrets` → `central-accesstoken`.

`central-accesstoken` creates the `ApplicationIdentity` `platform-system/central-accesstoken-eso` and the `ClusterSecretStore` `central-accesstoken-store`, usable only from namespaces labeled `accesstoken.dis.altinn.cloud/enabled: "true"`. The store reports NotReady until the managed identity dis-identity-operator creates for `central-accesstoken-eso` has Key Vault Secrets User on the token secret. Grant it on that secret only, not on the shared vault.

Disabling the flag removes the kustomizations and the `external-secrets-operator-central-accesstoken-kv-url` Key Vault secret, but leaves the identity, the store and the `platform-system/external-secrets-operator-vars` ExternalSecret from `multitenancy/secrets` in the cluster: all three are annotated `kustomize.toolkit.fluxcd.io/prune: disabled`, and removing them is a manual step. The ExternalSecret uses the default `deletionPolicy: Retain`, so after the Key Vault secret is gone it keeps the `external-secrets-operator-vars` Secret and reports `SecretSyncedError` until it is deleted.

## Flux dispatch tokens

Add entries to `flux_dispatch_tokens` to give product namespaces GitHub tokens for Flux `githubdispatch` Providers ([RFC 0019](https://github.com/Altinn/altinn-platform/blob/main/rfcs/0019-flux-workflow-notifications.md)). Each token works for one repository only. Set `flux_dispatch_github_app_id` and `flux_dispatch_github_app_installation_id` to the shared GitHub App. They need the external-secrets-operator release with the `multitenancy/flux-dispatch-*` layers (dis-way/gitops-manifests#2424) in the `flux_release_tag` ring.

The module writes the two IDs and each entry's values to the dis-system Key Vault. It does not write the App private key: pass the key to the `secrets` input of the `dis_system_kv` module as `flux-dispatch-github-app-private-key`, which keeps it out of Terraform state. Until the key is in the vault, the kustomizations apply but no token is generated.

The first entry adds the `flux-dispatch-app` kustomization, and each entry adds `flux-dispatch-<name>-secrets` and `flux-dispatch-<name>`. They run in the order `post-deploy` → `flux-dispatch-app` and `flux-dispatch-<name>-secrets` → `flux-dispatch-<name>`. AKS limits kustomization names, so `<name>` is at most 15 characters.

Add the repository to the App installation together with its entry, and remove it when the entry goes. Removing an entry deletes its token objects, including the destination Secret, and its Key Vault secrets. It leaves the `platform-system/flux-dispatch-<name>-vars` ExternalSecret, which is annotated `kustomize.toolkit.fluxcd.io/prune: disabled`; delete it by hand. Removing the last entry also leaves the `platform-system/flux-dispatch-github-app` ExternalSecret and its Secret, which holds the private key.

Each entry needs its own Secret, so two entries cannot share a `token_namespace` and `token_secret_name`. Do not change an entry's `github_repository_name` and `token_namespace` at the same time: the token is renewed for the new repository only at the next refresh, up to 30 minutes later, and until then the new namespace gets a token for the old repository. Add an entry with a new name instead, then remove the old one.
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.cert_manager](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_cache_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_identity_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_pgsql_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.dis_vault_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.external_secrets_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.flux_webhook_receiver](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.gateway_api](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kro](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kube_state_metrics](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.kyverno_policies](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.lets_encrypt_tls_issuer](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.linkerd](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.opencost](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_collector](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.otel_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.traefik](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.valkey_operator](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_federated_identity_credential.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault_secret.central_accesstoken_kv_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.flux_dispatch](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.flux_substitute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.opencost_rate_card_query_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.opencost_metrics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
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
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Platform base tags (the RFC 0007 finops tag set) passed to the DIS operators, which apply them to every Azure resource they create. Empty disables operator platform tagging. | `map(string)` | `{}` | no |
| <a name="input_central_accesstoken_kv_uri"></a> [central\_accesstoken\_kv\_uri](#input\_central\_accesstoken\_kv\_uri) | Vault URI of the Key Vault holding the central access token, e.g. https://<name>.vault.azure.net/. Written to the dis-system Key Vault as external-secrets-operator-central-accesstoken-kv-url. Required when enable\_central\_accesstoken is true. | `string` | `""` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Deterministic, human-readable identifier of the cluster. dis-pgsql appends it to new Azure PostgreSQL Flexible Server names ("<db>-<cluster\_id>") to keep them globally unique across clusters, so it must be unique and stable per cluster. | `string` | `""` | no |
| <a name="input_default_gateway_hostname"></a> [default\_gateway\_hostname](#input\_default\_gateway\_hostname) | The default gateway hostname of the AKS cluster. This will be the Hostname in the default gateway https://gateway-api.sigs.k8s.io/reference/spec/#hostname. Leave empty only with enable\_default\_gateway\_hostname = false. | `string` | n/a | yes |
| <a name="input_dis_db_vnet_name"></a> [dis\_db\_vnet\_name](#input\_dis\_db\_vnet\_name) | Name of the VNet hosting DIS database resources. | `string` | `""` | no |
| <a name="input_dis_pgsql_uami_client_id"></a> [dis\_pgsql\_uami\_client\_id](#input\_dis\_pgsql\_uami\_client\_id) | Client id for the dis-pgsql workload identity. | `string` | `""` | no |
| <a name="input_dis_resource_group_name"></a> [dis\_resource\_group\_name](#input\_dis\_resource\_group\_name) | Name of the resource group where DIS operators create their resources. | `string` | `""` | no |
| <a name="input_dis_system_kv_client_id"></a> [dis\_system\_kv\_client\_id](#input\_dis\_system\_kv\_client\_id) | Client ID of the dis-system Key Vault reader identity (dis\_system\_kv\_reader\_client\_id output of the dis\_system\_kv module). Used by the dis-system-store SecretStore in platform-system. | `string` | n/a | yes |
| <a name="input_dis_system_kv_id"></a> [dis\_system\_kv\_id](#input\_dis\_system\_kv\_id) | Resource ID of the dis-system Key Vault (dis\_system\_kv\_id output of the dis\_system\_kv module). Every postBuild.substitute variable of the flux configurations is written to it as a secret, see flux-substitute-secrets.tf. | `string` | n/a | yes |
| <a name="input_dis_system_kv_uri"></a> [dis\_system\_kv\_uri](#input\_dis\_system\_kv\_uri) | Vault URI of the dis-system Key Vault (dis\_system\_kv\_uri output of the dis\_system\_kv module). | `string` | n/a | yes |
| <a name="input_dis_vault_aks_subnet_ids"></a> [dis\_vault\_aks\_subnet\_ids](#input\_dis\_vault\_aks\_subnet\_ids) | AKS subnet IDs passed to DIS Vault. | `string` | `""` | no |
| <a name="input_dis_vault_environment"></a> [dis\_vault\_environment](#input\_dis\_vault\_environment) | Environment name passed to DIS Vault. | `string` | `""` | no |
| <a name="input_dis_vault_location"></a> [dis\_vault\_location](#input\_dis\_vault\_location) | Azure location for DIS Vault resources. | `string` | `""` | no |
| <a name="input_dis_vault_vpn_exit_node_subnet_id"></a> [dis\_vault\_vpn\_exit\_node\_subnet\_id](#input\_dis\_vault\_vpn\_exit\_node\_subnet\_id) | Optional VPN exit node subnet ID passed to DIS Vault. Requires enable\_dis\_vault\_vpn\_exit\_node\_subnet = true. | `string` | `""` | no |
| <a name="input_enable_central_accesstoken"></a> [enable\_central\_accesstoken](#input\_enable\_central\_accesstoken) | Deploy the multitenancy/secrets and multitenancy/central-accesstoken layers of external-secrets-operator: the ApplicationIdentity central-accesstoken-eso in platform-system and the ClusterSecretStore central-accesstoken-store, usable only from namespaces labeled accesstoken.dis.altinn.cloud/enabled=true. The store stays NotReady until the managed identity dis-identity-operator creates for central-accesstoken-eso is granted Key Vault Secrets User on the token secret in central\_accesstoken\_kv\_uri. The vault is shared, so grant it on that secret only. | `bool` | `false` | no |
| <a name="input_enable_default_gateway_hostname"></a> [enable\_default\_gateway\_hostname](#input\_enable\_default\_gateway\_hostname) | Set to false when default\_gateway\_hostname is empty. A plan-time flag, so the hostname may be unknown until apply; it decides whether the traefik-default-gateway-hostname secret is written to the dis-system Key Vault. | `bool` | `true` | no |
| <a name="input_enable_dis_cache_operator"></a> [enable\_dis\_cache\_operator](#input\_enable\_dis\_cache\_operator) | Enable the dis-cache operator in the cluster. Needs enable\_valkey\_operator, because every cache runs on the Valkey operator. | `bool` | `false` | no |
| <a name="input_enable_dis_pgsql_operator"></a> [enable\_dis\_pgsql\_operator](#input\_enable\_dis\_pgsql\_operator) | Enable the dis-pgsql operator in the cluster. | `bool` | `false` | no |
| <a name="input_enable_dis_vault_operator"></a> [enable\_dis\_vault\_operator](#input\_enable\_dis\_vault\_operator) | Enable the dis-vault operator in the cluster. | `bool` | `false` | no |
| <a name="input_enable_dis_vault_vpn_exit_node_subnet"></a> [enable\_dis\_vault\_vpn\_exit\_node\_subnet](#input\_enable\_dis\_vault\_vpn\_exit\_node\_subnet) | Set to true when dis\_vault\_vpn\_exit\_node\_subnet\_id is provided. A plan-time flag, so the subnet ID may come from a subnet created in the same apply; it decides whether the dis-vault-disvault-vpn-exit-node-subnet-id secret is written to the dis-system Key Vault. | `bool` | `false` | no |
| <a name="input_enable_flux_webhook_receiver"></a> [enable\_flux\_webhook\_receiver](#input\_enable\_flux\_webhook\_receiver) | Enable on-demand Flux reconcile through the DIS edge by deploying the webhook receiver and dedicated Traefik listener. | `bool` | `false` | no |
| <a name="input_enable_lets_encrypt_tls_issuer"></a> [enable\_lets\_encrypt\_tls\_issuer](#input\_enable\_lets\_encrypt\_tls\_issuer) | Enable Let's Encrypt cert-manager issuer for TLS certificates | `bool` | `true` | no |
| <a name="input_enable_opencost"></a> [enable\_opencost](#input\_enable\_opencost) | Enable opencost | `bool` | `false` | no |
| <a name="input_enable_valkey_operator"></a> [enable\_valkey\_operator](#input\_enable\_valkey\_operator) | Enable the Valkey operator in the cluster. | `bool` | `false` | no |
| <a name="input_flux_dispatch_github_app_id"></a> [flux\_dispatch\_github\_app\_id](#input\_flux\_dispatch\_github\_app\_id) | App ID of the shared GitHub App that generates the flux\_dispatch\_tokens. Written to the dis-system Key Vault as flux-dispatch-github-app-id. Required when flux\_dispatch\_tokens is set. | `string` | `""` | no |
| <a name="input_flux_dispatch_github_app_installation_id"></a> [flux\_dispatch\_github\_app\_installation\_id](#input\_flux\_dispatch\_github\_app\_installation\_id) | Installation ID of the flux\_dispatch\_github\_app\_id App. Written to the dis-system Key Vault as flux-dispatch-github-app-installation-id. Required when flux\_dispatch\_tokens is set. | `string` | `""` | no |
| <a name="input_flux_dispatch_tokens"></a> [flux\_dispatch\_tokens](#input\_flux\_dispatch\_tokens) | GitHub tokens for Flux githubdispatch Providers (RFC 0019), keyed by a mapping name of at most 15 characters. For each mapping, platform-system renews a contents: write token for github\_repository\_name, a repository in the App installation named without its owner, and copies it to the Secret token\_secret\_name in token\_namespace. Needs flux\_dispatch\_github\_app\_id, flux\_dispatch\_github\_app\_installation\_id and the App private key in the dis-system Key Vault; see the README. | <pre>map(object({<br/>    github_repository_name = string<br/>    token_namespace        = string<br/>    token_secret_name      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_flux_release_tag"></a> [flux\_release\_tag](#input\_flux\_release\_tag) | OCI image that Flux should watch and reconcile | `string` | n/a | yes |
| <a name="input_lb_source_range_apim"></a> [lb\_source\_range\_apim](#input\_lb\_source\_range\_apim) | Additional IPv4 source range added to the load balancer alongside the hardcoded ranges in the Flux manifests. Defaults to loopback (127.0.0.1/32) meaning no additional source is granted. Override with the actual APIM IPv4 CIDR to allow APIM traffic. | `string` | `"127.0.0.1/32"` | no |
| <a name="input_lb_source_range_apim_ipv6"></a> [lb\_source\_range\_apim\_ipv6](#input\_lb\_source\_range\_apim\_ipv6) | Additional IPv6 source range added to the load balancer alongside the hardcoded ranges in the Flux manifests. Defaults to loopback (::1/128) meaning no additional source is granted. Override with the actual APIM IPv6 CIDR to allow APIM traffic. | `string` | `"::1/128"` | no |
| <a name="input_lb_source_range_dis_edge"></a> [lb\_source\_range\_dis\_edge](#input\_lb\_source\_range\_dis\_edge) | Additional IPv4 source range added to the load balancer alongside the hardcoded ranges in the Flux manifests. Defaults to loopback (127.0.0.1/32) meaning no additional source is granted. Override with the actual dis-edge IPv4 CIDR to allow dis-edge traffic. | `string` | `"127.0.0.1/32"` | no |
| <a name="input_lb_source_range_dis_edge_ipv6"></a> [lb\_source\_range\_dis\_edge\_ipv6](#input\_lb\_source\_range\_dis\_edge\_ipv6) | Additional IPv6 source range added to the load balancer alongside the hardcoded ranges in the Flux manifests. Defaults to loopback (::1/128) meaning no additional source is granted. Override with the actual dis-edge IPv6 CIDR to allow dis-edge traffic. | `string` | `"::1/128"` | no |
| <a name="input_linkerd_default_inbound_policy"></a> [linkerd\_default\_inbound\_policy](#input\_linkerd\_default\_inbound\_policy) | Default inbound policy for Linkerd | `string` | `"deny"` | no |
| <a name="input_linkerd_disable_ipv6"></a> [linkerd\_disable\_ipv6](#input\_linkerd\_disable\_ipv6) | Disable IPv6 for Linkerd | `string` | `"false"` | no |
| <a name="input_obs_tenant_id"></a> [obs\_tenant\_id](#input\_obs\_tenant\_id) | Tenant id for the observability app. | `string` | `""` | no |
| <a name="input_opencost_azure_monitoring_workspace_id"></a> [opencost\_azure\_monitoring\_workspace\_id](#input\_opencost\_azure\_monitoring\_workspace\_id) | Azure id of the monitoring workspace to read from | `string` | `""` | no |
| <a name="input_opencost_environment"></a> [opencost\_environment](#input\_opencost\_environment) | Name of the environment this opencost instance is deployed to. Eg: at22 | `string` | `""` | no |
| <a name="input_opencost_prometheus_endpoint"></a> [opencost\_prometheus\_endpoint](#input\_opencost\_prometheus\_endpoint) | URL of the prometheus endpint that opencost queries | `string` | `""` | no |
| <a name="input_opencost_resource_group_name"></a> [opencost\_resource\_group\_name](#input\_opencost\_resource\_group\_name) | Resource group where opencost user manage identities are created | `string` | `""` | no |
| <a name="input_otel_amw_write_endpoint"></a> [otel\_amw\_write\_endpoint](#input\_otel\_amw\_write\_endpoint) | Azure Monitor Workspaces write endpoint to write prometheus metrics to via prometheus exporter | `string` | n/a | yes |
| <a name="input_otel_client_id"></a> [otel\_client\_id](#input\_otel\_client\_id) | Client id for the federated identity used by otel | `string` | n/a | yes |
| <a name="input_otel_kv_uri"></a> [otel\_kv\_uri](#input\_otel\_kv\_uri) | Key vault uri for otel config | `string` | n/a | yes |
| <a name="input_otel_tenant_id"></a> [otel\_tenant\_id](#input\_otel\_tenant\_id) | Tenant id for the obs app | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription id where aks cluster and other resources are deployed | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id where aks cluster and other resources are deployed | `string` | n/a | yes |
| <a name="input_tls_lets_encrypt_workload_identity_client_id"></a> [tls\_lets\_encrypt\_workload\_identity\_client\_id](#input\_tls\_lets\_encrypt\_workload\_identity\_client\_id) | Client id for cert-manager workload identity (Let's Encrypt DNS issuer) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_name"></a> [tls\_lets\_encrypt\_zone\_name](#input\_tls\_lets\_encrypt\_zone\_name) | Azure DNS zone name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
| <a name="input_tls_lets_encrypt_zone_rg_name"></a> [tls\_lets\_encrypt\_zone\_rg\_name](#input\_tls\_lets\_encrypt\_zone\_rg\_name) | Azure DNS zone resource group name for TLS certificates (Let's Encrypt) | `string` | `""` | no |
