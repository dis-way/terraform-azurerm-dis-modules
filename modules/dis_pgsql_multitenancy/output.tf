output "subnet_ids" {
  description = "The IDs of the created subnets."
  value       = [for i in range(length(azurerm_subnet.postgresql_subnets)) : azurerm_subnet.postgresql_subnets[tostring(i)].id]
}

output "vnet_id" {
  description = "The ID of the created virtual network."
  value       = azurerm_virtual_network.postgresql.id
}

output "vnet_name" {
  description = "The name of the created virtual network."
  value       = azurerm_virtual_network.postgresql.name
}

output "dispgsql_uami_client_id" {
  description = "The client ID of the user assigned managed identity for dis-pgsql."
  value       = azurerm_user_assigned_identity.dispgsql_identity.client_id
}
