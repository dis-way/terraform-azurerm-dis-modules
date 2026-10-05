output "vault_id" {
  description = "ID of the Data Protection backup vault."
  value       = azurerm_data_protection_backup_vault.this.id
}

output "backup_instance_ids" {
  description = "Backup instance IDs, keyed like disk_ids."
  value       = { for k, v in azurerm_data_protection_backup_instance_disk.this : k => v.id }
}
