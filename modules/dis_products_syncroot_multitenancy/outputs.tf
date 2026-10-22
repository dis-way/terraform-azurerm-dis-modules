output "admin_group_id" {
  value       = var.admin_group_id
  description = "Object id of the product's admin group, for dis_products_cluster_access_multitenancy"
}

output "reader_group_id" {
  value       = var.reader_group_id
  description = "Object id of the product's reader group, for dis_products_cluster_access_multitenancy"
}
