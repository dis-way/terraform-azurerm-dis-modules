locals {
  # Extract cluster name from AKS resource ID
  # Azure resource ID format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ContainerService/managedClusters/{clusterName}
  _cluster_id_parts = var.azurerm_kubernetes_cluster_id != null ? split("/", var.azurerm_kubernetes_cluster_id) : []
  cluster_name      = length(local._cluster_id_parts) > 0 ? element(local._cluster_id_parts, length(local._cluster_id_parts) - 1) : null
}
