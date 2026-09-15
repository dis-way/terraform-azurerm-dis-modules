resource "azurerm_key_vault_secret" "this" {
  # Secret names are not sensitive (they appear in the vault and in the External Secrets
  # manifests), so unmarking the keys for for_each is safe. Values are read back out of
  # the sensitive map and keep their marks.
  for_each = nonsensitive(toset(keys(var.secrets)))

  depends_on   = [azurerm_role_assignment.ci_kv_secrets_role]
  name         = each.value
  value        = var.secrets[each.value]
  key_vault_id = azurerm_key_vault.dis_system_kv.id
}
