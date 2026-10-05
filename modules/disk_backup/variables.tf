variable "name" {
  type        = string
  description = "Name of the Data Protection backup vault."
}

variable "location" {
  type        = string
  description = "Azure region of the vault and the disks it protects."
}

variable "resource_group_id" {
  type        = string
  description = "ID of an existing resource group that holds the vault and the disk snapshots."
}

variable "disk_ids" {
  type        = map(string)
  description = "Managed disk IDs to back up, keyed by backup instance name (e.g. 'headscale-data')."
}

variable "backup_start_time" {
  type        = string
  default     = "2026-10-06T00:00:00+00:00"
  description = "ISO 8601 anchor for the backup schedule."
}

variable "backup_interval" {
  type        = string
  default     = "PT4H"
  description = "ISO 8601 interval between snapshots: PT1H, PT2H, PT4H, PT6H, PT8H, PT12H or P1D."
  validation {
    condition     = contains(["PT1H", "PT2H", "PT4H", "PT6H", "PT8H", "PT12H", "P1D"], var.backup_interval)
    error_message = "backup_interval must be one of PT1H, PT2H, PT4H, PT6H, PT8H, PT12H or P1D."
  }
}

variable "retention_duration" {
  type        = string
  default     = "P14D"
  description = "ISO 8601 duration snapshots are kept (e.g. P14D)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the vault."
}
