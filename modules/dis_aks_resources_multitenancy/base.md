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
}
```

## Flux webhook receiver

`enable_flux_webhook_receiver` lets a publishing workflow ask Flux, through the DIS edge, to reconcile a product's artifact right after the push ([RFC 0017](https://github.com/Altinn/altinn-platform/blob/main/rfcs/0017-on-demand-flux-reconcile.md)). The flag defaults to `false`. With the flag off, the module plans the same resources as before.

With the flag on, the module:

- deploys the `traefik` package from the layer `./multitenancy-flux-webhook/` instead of `./multitenancy/`. The layer adds the `flux-webhook` entrypoint and Gateway listener, and a dedicated LoadBalancer Service on port 9443 of the shared public addresses (`aks_public_ipv4_address` and `aks_public_ipv6_address`). Only `lb_source_range_dis_edge` and `lb_source_range_dis_edge_ipv6` can connect to that port. The `post-deploy` layer does not change.
- deploys the `flux-webhook-receiver` package (layer `./multitenancy/`), which routes `https://flux-webhook.<default_gateway_hostname>/hook/...` from that listener to the Flux notification-controller.

Before a stack sets the flag:

- The gitops-manifests releases on the stack's ring (`flux_release_tag`, for example `at_ring2`) must include the `traefik` package with the `multitenancy-flux-webhook` layer and the `flux-webhook-receiver` package. Otherwise the `traefik` Kustomization cannot find its path and stops reconciling, and the `flux-webhook-receiver` source finds no artifact.
- `lb_source_range_dis_edge` and `lb_source_range_dis_edge_ipv6` must be the outbound ranges of the environment's DIS edge cluster, in canonical CIDR form. The validation rejects a value that is not a CIDR of the right IP family, has host bits set, has prefix length 0 (`0.0.0.0/0`, `::/0`), or is a loopback default (`127.0.0.1/32`, `::1/128`). AKS writes a deny-all rule for the whole shared address when a Service on it has a source range that is not valid.
- `default_gateway_hostname` must not be empty. The existing wildcard DNS record and certificate cover the webhook host name.

A product `Receiver` of type `generic-oidc` needs Flux 2.9 (`microsoft.flux` extension 1.26.1 or later). The flag itself does not.

```hcl
  enable_flux_webhook_receiver  = true
  lb_source_range_dis_edge      = "192.0.2.0/28"
  lb_source_range_dis_edge_ipv6 = "2001:db8::/124"
```

Setting the flag back to `false` restores `./multitenancy/` and deletes the `flux-webhook-receiver` Flux configuration. Its Kustomization prunes, so Flux removes the objects of the package.
