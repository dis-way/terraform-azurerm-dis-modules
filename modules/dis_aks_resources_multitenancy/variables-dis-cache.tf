variable "enable_dis_cache_operator" {
  type        = bool
  default     = false
  description = "Enable the dis-cache operator in the cluster. Needs enable_valkey_operator, because every cache runs on the Valkey operator."

  validation {
    condition     = var.enable_dis_cache_operator == false || var.enable_valkey_operator == true
    error_message = "enable_dis_cache_operator needs enable_valkey_operator = true."
  }
}
