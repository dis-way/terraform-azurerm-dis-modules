output "peering_id" {
  description = "ID of the local-to-remote VNet peering"
  value       = azurerm_virtual_network_peering.local_to_remote.id
}
