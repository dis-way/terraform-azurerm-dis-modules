variable "obs_amw_write_endpoint" {
  type        = string
  description = "Azure Monitor Workspaces write endpoint to write prometheus metrics to via prometheus exporter"
}

variable "obs_client_id" {
  type        = string
  description = "Client id for the obs app"
}

variable "obs_kv_uri" {
  type        = string
  description = "Key vault uri for observability"
}

variable "obs_tenant_id" {
  type        = string
  description = "Tenant id for the obs app"
}
