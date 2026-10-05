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
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 5.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk) | resource |
| [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_role_assignment.disk_backup_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.snapshot_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backup_interval"></a> [backup\_interval](#input\_backup\_interval) | ISO 8601 interval between snapshots: PT1H, PT2H, PT4H, PT6H, PT8H, PT12H or P1D. | `string` | `"PT4H"` | no |
| <a name="input_backup_start_time"></a> [backup\_start\_time](#input\_backup\_start\_time) | ISO 8601 anchor for the backup schedule. | `string` | `"2026-10-06T00:00:00+00:00"` | no |
| <a name="input_disk_ids"></a> [disk\_ids](#input\_disk\_ids) | Managed disk IDs to back up, keyed by backup instance name (e.g. 'headscale-data'). | `map(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region of the vault and the disks it protects. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Data Protection backup vault. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of an existing resource group that holds the vault and the disk snapshots. | `string` | n/a | yes |
| <a name="input_retention_duration"></a> [retention\_duration](#input\_retention\_duration) | ISO 8601 duration snapshots are kept (e.g. P14D). | `string` | `"P14D"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the vault. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backup_instance_ids"></a> [backup\_instance\_ids](#output\_backup\_instance\_ids) | Backup instance IDs, keyed like disk\_ids. |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | ID of the Data Protection backup vault. |
