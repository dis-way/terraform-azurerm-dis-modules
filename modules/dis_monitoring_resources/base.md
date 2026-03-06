# dis_monitoring_resources

Sets up AKS observability infrastructure: Azure Monitor Workspace, data collection rules, OpenTelemetry collector identity, Lakmus identity, Key Vault, and Prometheus recording rules.

## Usage

```hcl
module "dis_monitoring_resources" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_monitoring_resources?ref=<version>"

  prefix          = var.prefix
  environment     = var.environment
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  azurerm_kubernetes_cluster_id  = module.aks.cluster_id
  azurerm_resource_group_obs_name = var.obs_resource_group_name
  oidc_issuer_url                = module.aks.oidc_issuer_url

  monitor_workspace_id   = var.monitor_workspace_id
  monitor_workspace_name = var.monitor_workspace_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_insights_connection_string = var.app_insights_connection_string
  ci_service_principal_object_id = var.ci_service_principal_object_id
}
```
