output "servicebus_namespace_id" {
  description = "Resource ID of the Azure Service Bus namespace (DISMSG_NAMESPACE_RESOURCE_ID of the operator)."
  value       = azurerm_servicebus_namespace.messaging.id
}

output "servicebus_namespace_name" {
  description = "Name of the Azure Service Bus namespace."
  value       = azurerm_servicebus_namespace.messaging.name
}

output "servicebus_namespace_host" {
  description = "Host name of the Azure Service Bus namespace, <name>.servicebus.windows.net, taken from the endpoint URL."
  value       = regex("^https://([^:/]+)", azurerm_servicebus_namespace.messaging.endpoint)[0]
}

output "dismessaging_uami_client_id" {
  description = "Client ID of the user-assigned identity of dis-messaging-operator."
  value       = azurerm_user_assigned_identity.dismessaging_identity.client_id
}

output "dismessaging_uami_principal_id" {
  description = "Principal ID of the user-assigned identity of dis-messaging-operator."
  value       = azurerm_user_assigned_identity.dismessaging_identity.principal_id
}
