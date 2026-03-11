# Assign "Network Contributor" Role to AKS control-plane managed identity.
# Scoped to the resource group so the identity can manage the VNet (API server VNet
# integration), subnets, and outbound public IP prefixes (required for load balancer sync).
# Must be pre-assigned before cluster creation.
resource "azurerm_role_assignment" "network_contributor" {
  scope                            = azurerm_resource_group.aks.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks_control_plane.principal_id
  skip_service_principal_aad_check = true
}

# Assign "Network Contributor" Role on the AKS VNet to additional service principals (e.g. external managed identities)
resource "azurerm_role_assignment" "vnet_network_contributor" {
  for_each                         = toset(var.vnet_network_contributor_object_ids)
  scope                            = azurerm_virtual_network.aks.id
  role_definition_name             = "Network Contributor"
  principal_id                     = each.value
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

# Assign pull permission in listed ACR
resource "azurerm_role_assignment" "aks_acrpull" {
  for_each                         = toset(var.aks_acrpull_scopes)
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = each.value
  skip_service_principal_aad_check = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Assign Azure Kubernetes Service Cluster User Role to user groups
resource "azurerm_role_assignment" "aks_user_role" {
  for_each = {
    for value in var.aks_user_role_scopes : value => value if value != null
  }
  principal_id                     = each.value
  role_definition_name             = "Azure Kubernetes Service Cluster User Role"
  scope                            = azurerm_kubernetes_cluster.aks.id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Assign Private DNS Zone Contributor on the AKS node resource group (e.g. for workload identities managing private DNS)
resource "azurerm_role_assignment" "private_dns_zone_contributor" {
  for_each                         = toset(var.private_dns_zone_contributor_object_ids)
  scope                            = azurerm_kubernetes_cluster.aks.node_resource_group_id
  role_definition_name             = "Private DNS Zone Contributor"
  principal_id                     = each.value
  skip_service_principal_aad_check = true
}
