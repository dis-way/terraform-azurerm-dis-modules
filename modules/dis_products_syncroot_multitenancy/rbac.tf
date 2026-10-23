# Cluster-scoped access (RBAC Reader, Cluster User Role) is per group, not per product,
# and lives in dis_products_cluster_access_multitenancy. Feed it this module's
# admin_group_id and reader_group_id outputs.

resource "azurerm_role_assignment" "namespace_admin" {
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = var.admin_group_id
  scope                = "${var.aks_cluster_id}/namespaces/product-${var.product}"
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "namespace_reader" {
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.reader_group_id
  scope                = "${var.aks_cluster_id}/namespaces/product-${var.product}"
  principal_type       = "Group"
}
