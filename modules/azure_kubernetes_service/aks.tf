resource "azurerm_user_assigned_identity" "aks_control_plane" {
  name                = "${var.prefix}-${var.environment}-aks-identity"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  lifecycle {
    ignore_changes = [
      windows_profile,
      microsoft_defender,
    ]
    precondition {
      condition     = !var.system_pool_config.capacity_reservation_enabled || contains(local.capacity_reservation_vm_sizes, lower(var.system_pool_config.vm_size))
      error_message = "system_pool_config has capacity_reservation_enabled but its vm_size ${var.system_pool_config.vm_size} has no entry in capacity_reservations."
    }
  }
  # The reservations and the identity's role must exist before the system pool joins the group.
  depends_on = [
    azurerm_role_assignment.network_contributor,
    azurerm_capacity_reservation.aks,
    azurerm_role_assignment.capacity_reservation_contributor,
  ]
  name                      = var.azurerm_kubernetes_cluster_aks_name != "" ? var.azurerm_kubernetes_cluster_aks_name : "${var.prefix}-${var.environment}-aks"
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  dns_prefix                = "${var.prefix}-${var.environment}"
  sku_tier                  = var.aks_sku_tier
  kubernetes_version        = var.kubernetes_version
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  local_account_disabled    = var.aks_local_account_disabled

  # Only written when KEDA is on. With every autoscaler off, AKS returns no
  # workloadAutoScalerProfile, so a static block with keda_enabled = false plans an
  # in-place update on every run (hashicorp/terraform-provider-azurerm#22360, unfixed).
  dynamic "workload_autoscaler_profile" {
    for_each = var.enable_keda ? [1] : []
    content {
      keda_enabled = true
    }
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  default_node_pool {
    name                         = "syspool"
    os_sku                       = "AzureLinux"
    vnet_subnet_id               = azurerm_subnet.system_pool.id
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "syspool99"
    max_pods                     = 200
    # ForceNew on the whole cluster: on an existing cluster attach the pool with the CLI first.
    capacity_reservation_group_id = var.system_pool_config.capacity_reservation_enabled ? azurerm_capacity_reservation_group.aks[0].id : null
    auto_scaling_enabled          = var.system_pool_config.auto_scaling_enabled
    node_count                    = var.system_pool_config.auto_scaling_enabled ? null : var.system_pool_config.node_count
    vm_size                       = var.system_pool_config.vm_size
    min_count                     = var.system_pool_config.auto_scaling_enabled ? var.system_pool_config.min_count : null
    max_count                     = var.system_pool_config.auto_scaling_enabled ? var.system_pool_config.max_count : null
    zones                         = var.system_pool_config.zones
    orchestrator_version          = var.kubernetes_version
    os_disk_type                  = var.system_pool_config.ephemeral_os_disk ? "Ephemeral" : "Managed"
    os_disk_size_gb               = var.system_pool_config.ephemeral_os_disk ? (can(regex("Standard_[DE]2[a-z]*s_v[0-9]+", var.system_pool_config.vm_size)) ? 110 : null) : 128

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
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    ip_versions         = ["IPv4", "IPv6"] # Azure did not like IPv6 first
    pod_cidrs           = length(var.azurerm_kubernetes_cluster_aks_pod_cidrs) > 0 ? var.azurerm_kubernetes_cluster_aks_pod_cidrs : ["10.240.0.0/16", "fd10:59f0:8c79:240::/64"]
    service_cidrs       = length(var.azurerm_kubernetes_cluster_aks_service_cidrs) > 0 ? var.azurerm_kubernetes_cluster_aks_service_cidrs : ["10.250.0.0/24", "fd10:59f0:8c79:250::/108"]
    dns_service_ip      = var.azurerm_kubernetes_cluster_aks_dns_service_ip != "" ? var.azurerm_kubernetes_cluster_aks_dns_service_ip : "10.250.0.10"
    load_balancer_sku   = "standard"

    load_balancer_profile {
      outbound_ip_prefix_ids = [
        azurerm_public_ip_prefix.prefix4.id,
        azurerm_public_ip_prefix.prefix6.id
      ]
      outbound_ports_allocated = var.load_balancer_outbound_ports_allocated
      idle_timeout_in_minutes  = var.load_balancer_idle_timeout_in_minutes
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_control_plane.id]
  }

  api_server_access_profile {
    subnet_id                           = azurerm_subnet.api_server.id
    virtual_network_integration_enabled = true
  }

  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = true

  monitor_metrics {}

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
    msi_auth_for_monitoring_enabled = true
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = "1"
    duration    = "5"
    day_of_week = "Monday"
    start_time  = "23:30"
    utc_offset  = "+00:00"
  }
  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = "1"
    duration    = "5"
    day_of_week = "Tuesday"
    start_time  = "23:30"
    utc_offset  = "+00:00"
  }

  tags = merge(var.tags, var.flux_ring == null ? {} : { "flux-ring" = var.flux_ring })
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name               = "AKS-Diagnostics"
  target_resource_id = azurerm_kubernetes_cluster.aks.id
  storage_account_id = azurerm_storage_account.aks_log.id

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }
}
