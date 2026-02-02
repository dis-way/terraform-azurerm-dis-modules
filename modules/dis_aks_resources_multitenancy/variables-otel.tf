variable "otel_client_id" {
  type        = string
  description = "Client id for the federated identity used by otel"
}

variable "otel_kv_uri" {
  type        = string
  description = "Key vault uri for otel config"
}

variable "otel_tenant_id" {
  type        = string
  description = "Tenant id for the obs app"
}

variable "otel_amw_write_endpoint" {
  type        = string
  description = "Azure Monitor Workspaces write endpoint to write prometheus metrics to via prometheus exporter"
}