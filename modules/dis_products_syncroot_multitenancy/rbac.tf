resource "azurerm_role_assignment" "namespace_admin" {
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = var.admin_group_id
  scope                = "${var.aks_cluster_id}/namespaces/product-${var.product}"
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "cluster_reader" {
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.admin_group_id
  scope                = var.aks_cluster_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "namespace_reader" {
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.reader_group_id
  scope                = "${var.aks_cluster_id}/namespaces/product-${var.product}"
  principal_type       = "Group"
}
