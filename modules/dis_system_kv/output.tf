output "dis_system_kv_reader_client_id" {
  value = azurerm_user_assigned_identity.dis_sync_identity.client_id
}

output "dis_system_kv_uri" {
  value = azurerm_key_vault.dis_system_kv.vault_uri
}
