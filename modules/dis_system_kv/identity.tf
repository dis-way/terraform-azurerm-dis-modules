resource "azurerm_user_assigned_identity" "dis_sync_identity" {
  name                = var.override_user_assigned_identity_name != "" ? var.override_user_assigned_identity_name : "dis-sys-kv-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "dis_sync_fic" {
  name                      = "dis-sys-kv-${var.prefix}-${var.environment}"
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = var.azurerm_kubernetes_cluster_oidc_issuer_url
  subject                   = "system:serviceaccount:${var.dis_system_kv_namespace}:${var.dis_system_kv_service_account_name}"
  user_assigned_identity_id = azurerm_user_assigned_identity.dis_sync_identity.id
}
