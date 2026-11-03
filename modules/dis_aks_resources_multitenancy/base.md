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

Disabling the flag removes the kustomizations, but leaves the identity and store in the cluster: both are annotated `kustomize.toolkit.fluxcd.io/prune: disabled`, and removing them is a manual step.
