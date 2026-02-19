variable "environment" {
  type        = string
  description = "Environment"
  validation {
    condition     = length(var.environment) > 0
    error_message = "You must provide a value for environment."
  }
}

variable "syncroot_namespace" {
  type        = string
  description = "The namespace to use for the syncroot. This is the containing 'folder' in altinncr repo and the namespace in the cluster. If empty, syncroot will not be deployed."
  default     = ""
}
