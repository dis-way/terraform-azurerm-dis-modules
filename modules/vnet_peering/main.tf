resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                      = "${var.peering_name_prefix}-local-to-remote"
  resource_group_name       = var.local_resource_group_name
  virtual_network_name      = var.local_vnet_name
  remote_virtual_network_id = var.remote_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
