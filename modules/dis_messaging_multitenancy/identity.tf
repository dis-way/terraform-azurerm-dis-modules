resource "azurerm_user_assigned_identity" "dismessaging_identity" {
  name                = var.user_assigned_identity_name != "" ? var.user_assigned_identity_name : "dis-messaging-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "dismessaging_fic" {
  name                      = "dis-messaging-aks-${var.prefix}-${var.environment}"
  user_assigned_identity_id = azurerm_user_assigned_identity.dismessaging_identity.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = var.oidc_issuer_url
  subject  = "system:serviceaccount:dis-messaging-operator-system:dis-messaging-operator-controller-manager"
}

# Reader on the namespace: the operator lists the queues for its inventory. Queues and
# role assignments are created through ASO with the ASO identity, not with this one.
resource "azurerm_role_assignment" "dismessaging_namespace_reader" {
  scope                            = azurerm_servicebus_namespace.messaging.id
  role_definition_name             = "Reader"
  principal_id                     = azurerm_user_assigned_identity.dismessaging_identity.principal_id
  skip_service_principal_aad_check = true
}
