resource "azurerm_monitor_data_collection_endpoint" "amw" {
  name                = "${var.prefix}-${var.environment}-mdce"
  resource_group_name = var.azurerm_resource_group_obs_name
  location            = var.location
  kind                = "Linux"
  tags = merge(var.localtags, {
    submodule = "observability"
  })
}

resource "azurerm_monitor_data_collection_rule" "amw" {
  name                        = "${var.prefix}-${var.environment}-mdcr"
  resource_group_name         = var.azurerm_resource_group_obs_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.amw.id
  kind                        = "Linux"
  tags = merge(var.localtags, {
    submodule = "observability"
  })

  destinations {
    monitor_account {
      monitor_account_id = var.monitor_workspace_id
      name               = var.monitor_workspace_name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = [var.monitor_workspace_name]
  }


  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.amw
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "amw" {
  name                    = "${var.prefix}-${var.environment}-mdcra"
  target_resource_id      = var.azurerm_kubernetes_cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.amw.id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.amw
  ]
}
