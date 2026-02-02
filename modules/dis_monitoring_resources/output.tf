output "key_vault_uri" {
  value     = azurerm_key_vault.obs_kv.vault_uri
  sensitive = true
}

output "obs_client_id" {
  value     = azurerm_user_assigned_identity.otel_collector.client_id
  sensitive = true
}

output "lakmus_client_id" {
  value       = var.enable_lakmus ? azurerm_user_assigned_identity.lakmus[0].client_id : ""
  sensitive   = true
  description = "The client ID of the user assigned identity used by lakmus."
}

output "monitor_workspace_write_endpoint" {
  value       = "${azurerm_monitor_data_collection_endpoint.amw.metrics_ingestion_endpoint}/dataCollectionRules/${azurerm_monitor_data_collection_rule.amw.immutable_id}/streams/Microsoft-PrometheusMetrics/api/v1/write?api-version=2023-04-24"
  description = "Metrics ingestion endpoint url"
}
