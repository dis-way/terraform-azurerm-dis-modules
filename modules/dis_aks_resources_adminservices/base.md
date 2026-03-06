# dis_aks_resources_adminservices

Deploys admin/platform services onto an AKS cluster: cert-manager, External Secrets Operator, Flux syncroot, Grafana operator, Lakmus, Linkerd, OpenTelemetry, and Traefik.

## Usage

```hcl
module "dis_aks_resources_adminservices" {
  source = "git::https://github.com/dis-way/terraform-azurerm-dis-modules.git//modules/dis_aks_resources_adminservices?ref=<version>"

  azurerm_kubernetes_cluster_id = module.aks.cluster_id
  subscription_id               = var.subscription_id
  environment                   = var.environment

  developer_entra_id_group = var.developer_entra_id_group

  aks_node_resource_group = module.aks.node_resource_group
  aks_vnet_ipv4_cidr      = var.aks_vnet_ipv4_cidr
  aks_vnet_ipv6_cidr      = var.aks_vnet_ipv6_cidr
  pip4_ip_address         = module.aks.pip4_ip_address
  pip6_ip_address         = module.aks.pip6_ip_address

  obs_amw_write_endpoint = module.dis_monitoring_resources.amw_write_endpoint
  obs_client_id          = module.dis_monitoring_resources.obs_client_id
  obs_kv_uri             = module.dis_monitoring_resources.kv_uri
  obs_tenant_id          = var.tenant_id

  lakmus_client_id = module.dis_monitoring_resources.lakmus_client_id
}
```