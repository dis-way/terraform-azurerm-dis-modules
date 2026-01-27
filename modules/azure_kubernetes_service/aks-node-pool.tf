resource "azurerm_kubernetes_cluster_node_pool" "pools" {
  for_each = var.node_pool_configs



  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id        = azurerm_subnet.node_pools[each.key].id
  os_sku                = each.value.os_sku
  max_pods              = each.value.max_pods
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
  zones                 = each.value.zones
  orchestrator_version  = var.kubernetes_version
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  os_disk_type          = each.value.ephemeral_os_disk ? "Ephemeral" : "Managed"
  os_disk_size_gb       = each.value.ephemeral_os_disk ? (can(regex("Standard_D2[a-z]*s_v[0-9]+", each.value.vm_size)) ? 110 : null) : 128

  upgrade_settings {
    max_surge = "10%"
  }

  tags = var.tags
}
