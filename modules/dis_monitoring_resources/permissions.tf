resource "azurerm_role_assignment" "otel_collector_metrics_publisher" {
  scope                = azurerm_monitor_data_collection_rule.amw.id
  principal_id         = azurerm_user_assigned_identity.otel_collector.principal_id
  role_definition_name = "Monitoring Metrics Publisher"
}

resource "azurerm_role_assignment" "grafana_monitor_reader" {
  count                = var.grafana_principal_id != "" ? 1 : 0
  scope                = var.monitor_workspace_id
  role_definition_name = "Monitoring Reader"
  principal_id         = var.grafana_principal_id
}

resource "azurerm_role_assignment" "grafana_log_analytics_reader" {
  count                = var.grafana_principal_id != "" ? 1 : 0
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = var.grafana_principal_id
}

resource "azurerm_role_assignment" "grafana_deploy_monitor_reader" {
  count                = var.grafana_deploy_principal_id != "" ? 1 : 0
  scope                = var.monitor_workspace_id
  role_definition_name = "Monitoring Reader"
  principal_id         = var.grafana_deploy_principal_id
}

resource "azurerm_role_assignment" "developer_log_analytics_reader" {
  count                = var.developer_group_object_id != "" ? 1 : 0
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = var.developer_group_object_id
}
