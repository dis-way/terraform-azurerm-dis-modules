output "azuread_cert_manager_client_id" {
  description = "Client ID for the Entra ID application used by cert-manager."
  sensitive   = true
  value       = azuread_application.cert_manager_app.client_id
}

output "azurerm_dns_zone_name" {
  description = "The DNS name of the created child zone."
  value       = azurerm_dns_zone.child_zone.name
}

output "azurerm_dns_zone_resource_group_name" {
  description = "Resource group name containing the created child zone."
  value       = azurerm_dns_zone.child_zone.resource_group_name
}
