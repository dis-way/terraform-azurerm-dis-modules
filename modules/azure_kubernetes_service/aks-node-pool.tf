resource "azurerm_kubernetes_cluster_node_pool" "pools" {
  for_each = var.node_pool_configs

  lifecycle {
    precondition {
      condition     = !each.value.capacity_reservation_enabled || contains(local.capacity_reservation_vm_sizes, lower(each.value.vm_size))
      error_message = "Node pool ${each.key} has capacity_reservation_enabled but its vm_size ${each.value.vm_size} has no entry in capacity_reservations."
    }
  }

  # The reservations and the identity's role must exist before a pool joins the group. On
  # destroy this also removes the pool before the reservations under it.
  depends_on = [
    azurerm_capacity_reservation.aks,
    azurerm_role_assignment.capacity_reservation_contributor,
  ]

  name                        = each.key
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id              = azurerm_subnet.node_pools[each.key].id
  os_sku                      = each.value.os_sku
  max_pods                    = each.value.max_pods
  auto_scaling_enabled        = each.value.auto_scaling_enabled
  node_count                  = each.value.auto_scaling_enabled ? null : each.value.node_count
  vm_size                     = each.value.vm_size
  min_count                   = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count                   = each.value.auto_scaling_enabled ? each.value.max_count : null
  zones                       = each.value.zones
  orchestrator_version        = var.kubernetes_version
  node_labels                 = each.value.node_labels
  node_taints                 = each.value.node_taints
  os_disk_type                = each.value.ephemeral_os_disk ? "Ephemeral" : "Managed"
  os_disk_size_gb             = each.value.ephemeral_os_disk ? (can(regex("Standard_[DE]2[a-z]*s_v[0-9]+", each.value.vm_size)) ? 110 : null) : 128
  temporary_name_for_rotation = "${each.key}99"
  # ForceNew: opting an existing pool in or out deletes and recreates it.
  capacity_reservation_group_id = each.value.capacity_reservation_enabled ? azurerm_capacity_reservation_group.aks[0].id : null

  upgrade_settings {
    max_surge                 = "10%"
    undrainable_node_behavior = "Schedule"
  }

  dynamic "linux_os_config" {
    for_each = var.node_sysctl_config == null ? [] : [var.node_sysctl_config]
    content {
      sysctl_config {
        net_core_somaxconn           = linux_os_config.value.net_core_somaxconn
        net_ipv4_tcp_max_syn_backlog = linux_os_config.value.net_ipv4_tcp_max_syn_backlog
        net_core_netdev_max_backlog  = linux_os_config.value.net_core_netdev_max_backlog
      }
    }
  }

  tags = var.tags
}
