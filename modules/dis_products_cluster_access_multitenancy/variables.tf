variable "aks_cluster_id" {
  type        = string
  description = "The ID of the AKS cluster the groups get access to"
}

variable "admin_group_ids" {
  type        = set(string)
  description = "Object ids of the product admin groups. Each gets AKS RBAC Reader on the cluster and the Cluster User Role."
}

variable "reader_group_ids" {
  type        = set(string)
  description = "Object ids of the product reader groups. Each gets the Cluster User Role."
}
