resource "azurerm_role_assignment" "namespace_admin" {
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = var.admin_group_id
  scope                = "${var.aks_cluster_id}/namespaces/product-${var.product}"
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "cluster_reader" {
  count                = var.create_cluster_role_assignments ? 1 : 0
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.admin_group_id
  scope                = var.aks_cluster_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "get_credentials_admin_group" {
  count                = var.create_cluster_role_assignments ? 1 : 0
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
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

resource "azurerm_role_assignment" "get_credentials_reader_group" {
  count                = var.create_cluster_role_assignments ? 1 : 0
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.reader_group_id
  scope                = var.aks_cluster_id
  principal_type       = "Group"
}

moved {
  from = azurerm_role_assignment.cluster_reader
  to   = azurerm_role_assignment.cluster_reader[0]
}

moved {
  from = azurerm_role_assignment.get_credentials_admin_group
  to   = azurerm_role_assignment.get_credentials_admin_group[0]
}

moved {
  from = azurerm_role_assignment.get_credentials_reader_group
  to   = azurerm_role_assignment.get_credentials_reader_group[0]
}
