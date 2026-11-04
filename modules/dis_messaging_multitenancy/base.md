# dis_messaging_multitenancy

Creates the shared Azure Service Bus namespace of a cluster for `dis-messaging-operator` (RFC 0018), with Entra ID as the only authentication, an IP firewall, diagnostic logs, `prevent_destroy`, and for the Premium tier an autoscale setting from 1 to 2 messaging units. It also creates the user-assigned identity of the operator with a federated credential and the Reader role on the namespace.

The namespace must be created in the DIS resource group of the cluster (`module.aks.dis_resource_group_name`): the operator creates queues and role assignments through Azure Service Operator, whose custom role and role-assignment delegation are scoped to that group.

The firewall denies by default, so `allowed_ipv4_prefixes` must hold the AKS egress prefix (`module.aks.egress_ipv4_prefix`) and the public IPv4 address of the VPN exit node. The trusted-services bypass is set on the Premium tier only; the Standard tier does not have it.

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
  log_analytics_workspace_id = module.aks.products_log_analytics_workspace_id
  tags                       = local.tags
}
```
