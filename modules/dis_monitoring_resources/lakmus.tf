resource "azurerm_user_assigned_identity" "lakmus" {
  count               = var.enable_lakmus ? 1 : 0
  name                = "${var.prefix}-${var.environment}-lakmus"
  resource_group_name = var.azurerm_resource_group_obs_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "lakmus" {
  count               = var.enable_lakmus ? 1 : 0
  name                = "${var.prefix}-${var.environment}-lakmus"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:lakmus"
  resource_group_name = var.azurerm_resource_group_obs_name
  parent_id           = azurerm_user_assigned_identity.lakmus[0].id
}

# Gives key vault reader to the whole subscription
resource "azurerm_role_assignment" "kv_reader_lakmus" {
  count                            = var.enable_lakmus ? 1 : 0
  scope                            = "/subscriptions/${var.subscription_id}"
  role_definition_name             = "Key Vault Reader"
  principal_id                     = azurerm_user_assigned_identity.lakmus[0].principal_id
  skip_service_principal_aad_check = true
}
