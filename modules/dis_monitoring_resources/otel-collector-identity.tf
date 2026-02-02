resource "azurerm_user_assigned_identity" "otel_collector" {
  name                = "${var.prefix}-${var.environment}-otel-collector"
  resource_group_name = var.azurerm_resource_group_obs_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "otel_collector" {
  name                = "fed-identity-${var.prefix}-${var.environment}-otel-collector"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:otel-collector"
  resource_group_name = var.azurerm_resource_group_obs_name
  parent_id           = azurerm_user_assigned_identity.otel_collector.id
}
