# observability-module

A lightweight Terraform module that adds the neccesary dis flawor to the Azure monitoring stack

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.lakmus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault.obs_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.conn_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.kubernetes_recording_rules_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.node_recording_rules_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.ux_recording_rules_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_data_collection_endpoint.amw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint) | resource |
| [azurerm_monitor_data_collection_rule.amw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.amw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_role_assignment.ci_kv_secrets_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_reader_lakmus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.obs_kv_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.otel_collector_metrics_publisher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.lakmus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.otel_collector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.obs_kv_postfix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights_connection_string"></a> [app\_insights\_connection\_string](#input\_app\_insights\_connection\_string) | Connection string of an Application Insights where logs and traces are sendt. | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_id"></a> [azurerm\_kubernetes\_cluster\_id](#input\_azurerm\_kubernetes\_cluster\_id) | AKS cluster resource id | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_obs_name"></a> [azurerm\_resource\_group\_obs\_name](#input\_azurerm\_resource\_group\_obs\_name) | Name of the observability resource group where all the resources will be placed. | `string` | n/a | yes |
| <a name="input_ci_service_principal_object_id"></a> [ci\_service\_principal\_object\_id](#input\_ci\_service\_principal\_object\_id) | Object ID of the CI service principal used for role assignments. | `string` | n/a | yes |
| <a name="input_enable_lakmus"></a> [enable\_lakmus](#input\_enable\_lakmus) | Deploy the resources needed by lakmus | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for resources | `string` | n/a | yes |
| <a name="input_localtags"></a> [localtags](#input\_localtags) | A map of tags to assign to the created resources. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Region for resources | `string` | `"norwayeast"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ID of an existing Log Analytics Workspace when reusing. | `string` | n/a | yes |
| <a name="input_monitor_workspace_id"></a> [monitor\_workspace\_id](#input\_monitor\_workspace\_id) | ID of an existing Azure Monitor Workspace when reusing. | `string` | n/a | yes |
| <a name="input_monitor_workspace_name"></a> [monitor\_workspace\_name](#input\_monitor\_workspace\_name) | Name of an existing Azure Monitor Workspace when reusing. | `string` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | Oidc issuer url needed for federation | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID for resource deployments. | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD tenant ID for resource configuration. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | n/a |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | n/a |
| <a name="output_kubernetes_recording_rules_id"></a> [kubernetes\_recording\_rules\_id](#output\_kubernetes\_recording\_rules\_id) | ID of the Kubernetes Recording Rules rule group |
| <a name="output_lakmus_client_id"></a> [lakmus\_client\_id](#output\_lakmus\_client\_id) | The client ID of the user assigned identity used by lakmus. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | n/a |
| <a name="output_monitor_workspace_id"></a> [monitor\_workspace\_id](#output\_monitor\_workspace\_id) | n/a |
| <a name="output_monitor_workspace_write_endpoint"></a> [monitor\_workspace\_write\_endpoint](#output\_monitor\_workspace\_write\_endpoint) | Metrics ingestion endpoint url |
| <a name="output_node_recording_rules_id"></a> [node\_recording\_rules\_id](#output\_node\_recording\_rules\_id) | ID of the Node Recording Rules rule group |
| <a name="output_obs_client_id"></a> [obs\_client\_id](#output\_obs\_client\_id) | n/a |
| <a name="output_ux_recording_rules_id"></a> [ux\_recording\_rules\_id](#output\_ux\_recording\_rules\_id) | ID of the UX Recording Rules rule group |
<!-- END_TF_DOCS -->
---

## Quick start

```hcl
module "mon" {
  source = "dis_monitoring_resources"
  app_insights_connection_string = azurerm_application_insights.products.connection_string
  azurerm_kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  azurerm_resource_group_obs_name = azurerm_resource_group.monitor.name
  ci_service_principal_object_id = ""
  environment = var.environment
  location = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.products.id
  monitor_workspace_id = azurerm_monitor_workspace.products.id
  monitor_workspace_name = azurerm_monitor_workspace.products.name
  oidc_issuer_url = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  prefix = var.prefix
}
```