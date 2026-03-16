locals {
  prefix_length  = tonumber(split("/", var.vnet_address_space)[1])
  new_bits       = 28 - local.prefix_length
  subnet_count   = pow(2, local.new_bits)
  subnet_indices = toset([for i in range(local.subnet_count) : tostring(i)])
}

resource "azurerm_subnet" "postgresql_subnets" {
  for_each                          = local.subnet_indices
  address_prefixes                  = [cidrsubnet(var.vnet_address_space, local.new_bits, tonumber(each.value))]
  name                              = "${var.name}-subnet-${each.value}"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.postgresql.name
  private_endpoint_network_policies = "Enabled"
  service_endpoints                 = ["Microsoft.Storage"]
  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
