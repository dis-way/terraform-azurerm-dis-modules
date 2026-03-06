output "local_to_remote_peering_id" {
  description = "ID of the local-to-remote VNet peering"
  value       = azurerm_virtual_network_peering.local_to_remote.id
}

output "remote_to_local_peering_id" {
  description = "ID of the remote-to-local VNet peering"
  value       = azurerm_virtual_network_peering.remote_to_local.id
}
