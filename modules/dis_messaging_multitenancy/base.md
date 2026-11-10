# dis_messaging_multitenancy

Creates the shared Azure Service Bus namespace of a cluster for `dis-messaging-operator` (RFC 0018), with Entra ID as the only authentication, an IP firewall, diagnostic logs, `prevent_destroy`, and for the Premium tier an autoscale setting from 1 to 2 messaging units. It also creates the user-assigned identity of the operator with a federated credential and the Reader role on the namespace.

The module also deploys the operator to the cluster with a Flux configuration named `dis-messaging` in `platform-system`. The configuration reconciles the `./multitenancy/` path of the OCI artifact `oci://altinncr.azurecr.io/manifests/infra/dis-messaging` at the ring tag in `flux_release_tag`. It passes the subscription, the tenant, the resource ID of the Azure Service Bus namespace and the environment name to the operator as Flux substitutes. The operator creates queues through Azure Service Operator and uses no Azure identity of its own yet.

The namespace must be created in the DIS resource group of the cluster (`module.aks.dis_resource_group_name`): the operator creates queues and role assignments through Azure Service Operator, whose custom role and role-assignment delegation are scoped to that group.

The firewall denies by default, so `allowed_ipv4_prefixes` must hold the AKS egress prefix (`module.aks.egress_ipv4_prefix`) and the public IPv4 address of the VPN exit node. The trusted-services bypass is set on the Premium tier only; the Standard tier does not have it.

The public endpoint of the Azure Service Bus namespace is IPv4 only by default. Set `ip_address_type = "DualStack"` to add IPv6. `azurerm_servicebus_namespace` does not expose the property, so the module sets it with `azapi_update_resource`. Dual-stack clients prefer IPv6 as soon as the AAAA record exists. `allowed_ipv6_prefixes` must then hold the IPv6 egress prefix of the cluster (`module.aks.egress_ipv6_prefix`) and the IPv6 address of the VPN exit node. The module refuses DualStack with an empty `allowed_ipv6_prefixes`, and it applies the firewall rules before the flip. To go back, flip to IPv4 in one apply and remove the IPv6 prefixes in a later one.

## Usage

```hcl
module "dis_messaging_multitenancy" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_messaging_multitenancy?ref=<version>"

  prefix                     = var.team_name
  environment                = var.environment
  resource_group_name        = module.aks.dis_resource_group_name
  oidc_issuer_url            = module.aks.aks_oidc_issuer_url
  sku                        = "Standard" # Premium in tt02 and prod
  allowed_ipv4_prefixes      = [module.aks.egress_ipv4_prefix, var.vpn_exit_node_ipv4]
  ip_address_type            = "DualStack" # IPv4 is the default
  allowed_ipv6_prefixes      = [module.aks.egress_ipv6_prefix, var.vpn_exit_node_ipv6]
  log_analytics_workspace_id = module.aks.products_log_analytics_workspace_id
  tags                       = local.tags

  # Flux configuration of the operator
  kubernetes_cluster_id = module.aks.azurerm_kubernetes_cluster_id
  tenant_id             = data.azurerm_client_config.current.tenant_id
  flux_release_tag      = var.flux_release_tag # ring tag, for example at_ring1
}
```
