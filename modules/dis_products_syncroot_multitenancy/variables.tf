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
