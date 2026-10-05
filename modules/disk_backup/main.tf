locals {
  resource_group_name = provider::azurerm::parse_resource_id(var.resource_group_id)["resource_group_name"]
}

resource "azurerm_data_protection_backup_vault" "this" {
  name                = var.name
  resource_group_name = local.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_disk" "this" {
  name     = "disk-${lower(var.backup_interval)}-${lower(var.retention_duration)}"
  vault_id = azurerm_data_protection_backup_vault.this.id

  backup_repeating_time_intervals = ["R/${var.backup_start_time}/${var.backup_interval}"]
  default_retention_duration      = var.retention_duration
  time_zone                       = "UTC"
}

resource "azurerm_role_assignment" "snapshot_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "disk_backup_reader" {
  for_each = var.disk_ids

  scope                = each.value
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_disk" "this" {
  for_each = var.disk_ids

  name                         = each.key
  location                     = var.location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  disk_id                      = each.value
  snapshot_resource_group_name = local.resource_group_name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this.id

  depends_on = [
    azurerm_role_assignment.snapshot_contributor,
    azurerm_role_assignment.disk_backup_reader,
  ]
}
