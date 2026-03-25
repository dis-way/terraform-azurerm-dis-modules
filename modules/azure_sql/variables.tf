variable "location" {
  type        = string
  default     = "norwayeast"
  description = "Default region for resources"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names (required, max 8 characters). Combined with environment, must not exceed 12 characters for storage account naming."
  validation {
    condition     = length(var.prefix) > 0
    error_message = "You must provide a value for prefix for name generation."
  }
  validation {
    condition     = length(var.prefix) <= 8
    error_message = "Prefix must be 8 characters or less to avoid exceeding Azure storage account name limits (24 char max)."
  }
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment for resources (required, max 4 characters). Combined with prefix, must not exceed 12 characters for storage account naming."
  validation {
    condition     = length(var.environment) > 0
    error_message = "You must provide a value for environment."
  }
  validation {
    condition     = length(var.environment) <= 4
    error_message = "Environment must be 4 characters or less (e.g., 'dev', 'prod') to avoid exceeding Azure resource name limits."
  }
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "serverless" {
  type        = bool
  default     = true
  description = "Whether to deploy the database in serverless mode (GP_S_Gen5) or standard DTU mode (S-tier). When false, dtu_sku is used and serverless-specific settings (max_cores, min_cores, enable_autopause, autopause_after_mins) are ignored."
}

variable "max_cores" {
  type        = number
  default     = 2
  description = "Maximum vCores for serverless scaling. Only used when serverless = true."
  validation {
    condition     = contains([1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 80], var.max_cores)
    error_message = "max_cores must be one of: 1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, or 80."
  }
}

variable "min_cores" {
  type        = number
  default     = 0.5
  description = "Minimum vCores for serverless scaling. Must be at least 0.5 and no greater than max_cores. Only used when serverless = true."
  validation {
    condition     = var.min_cores >= 0.5 && var.min_cores <= var.max_cores
    error_message = "min_cores must be at least 0.5 and less than or equal to max_cores."
  }
}

variable "enable_autopause" {
  type        = bool
  default     = true
  description = "Whether to enable auto-pause for the serverless database. Only used when serverless = true."
}

variable "autopause_after_mins" {
  type        = number
  description = "Number of minutes of inactivity before auto-pause. Azure enforces a minimum of 60. Only used when serverless = true and enable_autopause = true."
  default     = 60
  validation {
    condition     = var.autopause_after_mins >= 60
    error_message = "autopause_after_mins must be at least 60 (Azure minimum)."
  }
}

variable "dtu_sku" {
  type        = string
  default     = "S2"
  description = "Standard DTU performance level to use when serverless = false. Valid values: S0, S1, S2, S3, S4, S6, S7, S9, S12."
  validation {
    condition     = contains(["S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12"], var.dtu_sku)
    error_message = "dtu_sku must be one of: S0, S1, S2, S3, S4, S6, S7, S9, S12."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the subnet in which to deploy the private endpoint for the SQL server."
  validation {
    condition     = length(var.private_endpoint_subnet_id) > 0
    error_message = "private_endpoint_subnet_id must not be empty."
  }
}

variable "private_dns_zone_id" {
  type        = string
  description = "The resource ID of the private DNS zone (privatelink.database.windows.net) to associate with the SQL private endpoint. Leave empty to skip DNS zone group creation."
  default     = ""
}

variable "server_version" {
  type        = string
  default     = "12.0"
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created."
  validation {
    condition     = contains(["2.0", "12.0"], var.server_version)
    error_message = "server_version must be either '2.0' (v11) or '12.0' (v12)."
  }
}

variable "database_name" {
  type        = string
  description = "Name of the database that will be deployed on this server"
  validation {
    condition     = length(var.database_name) > 0
    error_message = "database_name must not be empty."
  }
}

variable "database_admin_group_object_id" {
  type        = string
  description = "Database admin group object id. This group will be granted admin rights and the User Assigned Managed Identity created in this module will be added to the group. Terraform user needs permissions to add users to group"
  validation {
    condition     = can(regex("(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.database_admin_group_object_id))
    error_message = "database_admin_group_object_id must be a valid UUID."
  }
}

variable "database_admin_group_name" {
  type        = string
  description = "Database admin group name."
  validation {
    condition     = length(var.database_admin_group_name) > 0
    error_message = "You must provide a value for database_admin_group_name."
  }
}
