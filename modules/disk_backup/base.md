# disk_backup

Protects Azure managed disks with Azure Backup for Disks. Creates a Data Protection backup vault, one disk backup policy and a backup instance per disk. The vault's managed identity gets Disk Snapshot Contributor on the resource group and Disk Backup Reader on each disk. The vault and the snapshots share one resource group.

Backups are incremental snapshots, kept only in the operational tier. They stay in the same subscription and region as the disk.

## Usage

```hcl
data "azurerm_resources" "headscale_data_disk" {
  resource_group_name = module.aks.aks_node_resource_group
  type                = "Microsoft.Compute/disks"

  required_tags = {
    "kubernetes.io-created-for-pvc-namespace" = "headscale"
    "kubernetes.io-created-for-pvc-name"      = "headscale-data"
  }
}

module "disk_backup" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/disk_backup?ref=<version>"

  name              = "${var.team_name}-${var.environment}-bv"
  location          = azurerm_resource_group.backup.location
  resource_group_id = azurerm_resource_group.backup.id
  tags              = local.tags

  disk_ids = {
    headscale-data = one(data.azurerm_resources.headscale_data_disk.resources).id
  }
}
```
