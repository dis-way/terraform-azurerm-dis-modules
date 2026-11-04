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
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_federated_identity_credential.dismessaging_fic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_monitor_autoscale_setting.messaging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_monitor_diagnostic_setting.messaging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.dismessaging_namespace_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_servicebus_namespace.messaging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_user_assigned_identity.dismessaging_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowed_ipv4_prefixes"></a> [allowed\_ipv4\_prefixes](#input\_allowed\_ipv4\_prefixes) | IPv4 addresses or CIDR prefixes allowed through the namespace firewall, e.g. the AKS egress prefix and the VPN exit node. At least one is required: Azure does not enforce the Deny default action when the rule list is empty. Service Bus IP rules are IPv4 only. | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which the dis-messaging resources are created. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be created. | `string` | `"norwayeast"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ID of the Log Analytics workspace that receives the namespace diagnostic logs. | `string` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Optional override for the namespace name. Defaults to <prefix>-<environment>-messaging. | `string` | `""` | no |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | OIDC issuer URL of the AKS cluster, used by the federated credential of the operator identity. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix to be used for naming resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the DIS resource group of the cluster. The ASO custom role and its role-assignment delegation are scoped to this group, so the namespace must live here. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Tier of the Azure Service Bus namespace. Premium adds messaging units, autoscaling and the trusted-services firewall bypass. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources created. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | Optional override for the user-assigned identity name of dis-messaging-operator. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dismessaging_uami_client_id"></a> [dismessaging\_uami\_client\_id](#output\_dismessaging\_uami\_client\_id) | Client ID of the user-assigned identity of dis-messaging-operator. |
| <a name="output_dismessaging_uami_principal_id"></a> [dismessaging\_uami\_principal\_id](#output\_dismessaging\_uami\_principal\_id) | Principal ID of the user-assigned identity of dis-messaging-operator. |
| <a name="output_servicebus_namespace_host"></a> [servicebus\_namespace\_host](#output\_servicebus\_namespace\_host) | Host name of the Azure Service Bus namespace, <name>.servicebus.windows.net, taken from the endpoint URL. |
| <a name="output_servicebus_namespace_id"></a> [servicebus\_namespace\_id](#output\_servicebus\_namespace\_id) | Resource ID of the Azure Service Bus namespace (DISMSG\_NAMESPACE\_RESOURCE\_ID of the operator). |
| <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name) | Name of the Azure Service Bus namespace. |
