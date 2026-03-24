variable "product" {
  type        = string
  description = "Name of the product"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  validation {
    condition     = contains(["at22", "at23", "at24", "yt01", "tt02", "prod"], var.environment)
    error_message = "Environment must be one of: at22, at23, at24, yt01, tt02, prod"
  }
}

variable "prune_enabled" {
  type        = bool
  default     = false
  description = "Control if the syncroot enables prune of resources"
}

variable "aks_cluster_id" {
  type        = string
  description = "The ID of the AKS cluster where the Flux configuration will be applied"
}

variable "admin_group_id" {
  type        = string
  description = "Object id of the EntraID group that should have admin on the product namespace and reader in the cluster"
}

variable "reader_group_id" {
  type        = string
  description = "Object id of the EntraID group that should have reader permissions in the product namespace"
}

variable "substitute" {
  type        = map(string)
  sensitive   = true
  default     = {}
  description = "Key-value pairs for Flux postBuild variable substitution. All values are treated as sensitive."
}
