locals {
  # Composed name. Its total length is enforced by the validation on var.prefix.
  dis_system_kv_name = "${var.prefix}-${var.environment}-${random_string.dis_sys_kv_postfix.result}"
}

resource "random_string" "dis_sys_kv_postfix" {
  length  = var.key_vault_name_random_suffix_length
  special = false
  upper   = false
}

resource "azurerm_key_vault" "dis_system_kv" {
  name                       = local.dis_system_kv_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  tags                       = var.tags
  rbac_authorization_enabled = true
  purge_protection_enabled   = false # deliberate during testing
  soft_delete_retention_days = 7
}

resource "azurerm_role_assignment" "dis_system_kv_reader" {
  scope                            = azurerm_key_vault.dis_system_kv.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.dis_sync_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "ci_kv_secrets_role" {
  scope                            = azurerm_key_vault.dis_system_kv.id
  role_definition_name             = "Key Vault Secrets Officer" # read + write secrets only
  principal_id                     = var.ci_service_principal_object_id
  skip_service_principal_aad_check = true
}
