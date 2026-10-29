locals {
  capacity_reservation_enabled = length(var.capacity_reservations) > 0

  # vm_size is compared case-insensitively because callers write it in either case.
  capacity_reservation_vm_sizes = [for vm_size in keys(var.capacity_reservations) : lower(vm_size)]

  capacity_reservations = merge([
    for vm_size, capacity_by_zone in var.capacity_reservations : {
      for zone, capacity in capacity_by_zone : "${lower(vm_size)}-zone-${zone}" => {
        vm_size  = vm_size
        zone     = zone
        capacity = capacity
      }
    }
  ]...)
}

resource "azurerm_capacity_reservation_group" "aks" {
  count = local.capacity_reservation_enabled ? 1 : 0

  name                = "${var.azurerm_kubernetes_cluster_aks_name != "" ? var.azurerm_kubernetes_cluster_aks_name : "${var.prefix}-${var.environment}-aks"}-crg"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_capacity_reservation" "aks" {
  for_each = local.capacity_reservations

  name                          = each.key
  capacity_reservation_group_id = azurerm_capacity_reservation_group.aks[0].id
  zone                          = each.value.zone

  sku {
    name     = each.value.vm_size
    capacity = each.value.capacity
  }

  tags = var.tags
}

# AKS needs the control-plane identity to have Contributor on the capacity reservation group
# before a node pool can be associated with it. Scoped to the group itself rather than the
# whole resource group.
resource "azurerm_role_assignment" "capacity_reservation_contributor" {
  count = local.capacity_reservation_enabled ? 1 : 0

  scope                            = azurerm_capacity_reservation_group.aks[0].id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks_control_plane.principal_id
  skip_service_principal_aad_check = true
}
