variable "enable_products_azure_monitoring_resources" {
  type        = bool
  default     = true
  description = "Deploy observability resources in azure. This includes AI, LAW and AMW"
}

variable "products_log_analytics_retention_days" {
  type        = number
  default     = 30
  description = "Specifies the retention period in days for the products log analytics workspace"
  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.products_log_analytics_retention_days)
    error_message = "product_log_analytics_retention_days must be one of 30, 60, 90, 120, 180, 270, 365, 550 or 730"
  }
}
