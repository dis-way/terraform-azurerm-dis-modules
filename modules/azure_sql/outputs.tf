output "uami_id" {
  description = "The resource ID of the User Assigned Managed Identity used for SQL server authentication"
  value       = azurerm_user_assigned_identity.azsql.id
}

output "uami_principal_id" {
  description = "The principal (object) ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.azsql.principal_id
}

output "server_id" {
  description = "The resource ID of the SQL server"
  value       = azurerm_mssql_server.azsql.id
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.azsql.fully_qualified_domain_name
}

output "database_id" {
  description = "The resource ID of the SQL database"
  value       = azurerm_mssql_database.azsql.id
}

output "database_name" {
  description = "The name of the SQL database"
  value       = azurerm_mssql_database.azsql.name
}

output "private_endpoint_id" {
  description = "The resource ID of the SQL server private endpoint"
  value       = azurerm_private_endpoint.azsql.id
}

output "private_endpoint_ip" {
  description = "The private IP address allocated to the SQL server private endpoint"
  value       = azurerm_private_endpoint.azsql.private_service_connection[0].private_ip_address
}
