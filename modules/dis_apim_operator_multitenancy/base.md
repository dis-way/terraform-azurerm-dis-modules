### Minimal usage example
This module provisions a workload identity (user-assigned managed identity + federated credential) and deploys the DIS APIM operator to an AKS cluster via an AKS Flux configuration (OCI source).

```hcl
module "dis_apim_operator_multitenancy" {
  source = "./modules/dis_apim_operator_multitenancy"

  # AKS
  kubernetes_cluster_id              = module.aks.azurerm_kubernetes_cluster_id
  kubernetes_cluster_oidc_issuer_url = module.aks.aks_oidc_issuer_url
  kubernetes_node_resource_group     = module.aks.aks_node_resource_group
  kubernetes_node_location           = "norwayeast"

  # APIM
  apim_id                  = azurerm_api_management.apim.id
  apim_subscription_id      = data.azurerm_client_config.current.subscription_id
  apim_resource_group_name  = azurerm_api_management.apim.resource_group_name
  apim_service_name         = azurerm_api_management.apim.name
  default_logger_name       = "apim-default-logger"

  # Operator settings
  target_namespace = "platform-system"
  # namespace_suffix = "-tenant" # Optional: restrict reconciliation to namespaces ending with this suffix

  # Optional
  flux_release_tag = "latest"
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

