variable "local_vnet_name" {
  type        = string
  description = "Name of the local VNet"
}

variable "local_vnet_id" {
  type        = string
  description = "ID of the local VNet"
}

variable "local_resource_group_name" {
  type        = string
  description = "Resource group of the local VNet"
}

variable "remote_vnet_name" {
  type        = string
  description = "Name of the remote VNet"
}

variable "remote_vnet_id" {
  type        = string
  description = "ID of the remote VNet"
}

variable "remote_resource_group_name" {
  type        = string
  description = "Resource group of the remote VNet"
}

variable "peering_name_prefix" {
  type        = string
  description = "Prefix for naming the peering resources"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to peering resources"
}
