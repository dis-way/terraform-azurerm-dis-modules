# Log Analytics Workspace (create only if not reusing)
resource "azurerm_log_analytics_workspace" "products" {
  count               = var.enable_products_azure_monitoring_resources ? 1 : 0
  name                = "${var.prefix}-${var.environment}-products-law"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = var.location
  retention_in_days   = var.products_log_analytics_retention_days
  lifecycle { prevent_destroy = true }
  tags = merge(var.tags, {
    shared = "true"
  })
}

# Azure Monitor Workspace (create only if not reusing)
resource "azurerm_monitor_workspace" "products" {
  count               = var.enable_products_azure_monitoring_resources ? 1 : 0
  name                = "${var.prefix}-${var.environment}-products-amw"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = var.location
  lifecycle { prevent_destroy = true }
  tags = merge(var.tags, {
    shared = "true"
  })
}

# Application Insights (create only if not reusing)
resource "azurerm_application_insights" "products" {
  count               = var.enable_products_azure_monitoring_resources ? 1 : 0
  name                = "${var.prefix}-${var.environment}-products-ai"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.products[0].id
  application_type    = "web"
  retention_in_days   = 30
  lifecycle { prevent_destroy = true }
  tags = merge(var.tags, {
    shared = "true"
  })
}
