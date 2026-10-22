resource "azurerm_role_assignment" "cluster_reader" {
  for_each             = var.admin_group_ids
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = each.value
  scope                = var.aks_cluster_id
  principal_type       = "Group"
}

# Lets the groups fetch a kubeconfig. Keyed on the union so a group that is admin for one
# product and reader for another gets a single assignment.
resource "azurerm_role_assignment" "cluster_user" {
  for_each             = setunion(var.admin_group_ids, var.reader_group_ids)
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
  scope                = var.aks_cluster_id
  principal_type       = "Group"
}
