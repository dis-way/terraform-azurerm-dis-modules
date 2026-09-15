resource "azurerm_key_vault_secret" "this" {
  # Secret names are not sensitive (they appear in the vault and in the External Secrets
  # manifests), so unmarking the keys for for_each is safe. Values are provided via the
  # write-only value_wo argument so they do not remain in Terraform state.
  for_each = nonsensitive(toset(keys(var.secrets)))

  depends_on       = [azurerm_role_assignment.ci_kv_secrets_role]
  name             = each.value
  value_wo         = var.secrets[each.value]
  value_wo_version = try(var.secret_versions[each.value], 1)
  key_vault_id     = azurerm_key_vault.dis_system_kv.id
}
