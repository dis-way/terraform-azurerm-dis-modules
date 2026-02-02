### Minimal usage example
This module provisions the Azure resources needed for running Azure Service Operator (ASO) in AKS using workload identity, and configures ASO deployment via an AKS Flux configuration (OCI source).

```hcl
module "dis_azure_service_operator" {
  source = "./modules/dis_azure_service_operator"

  # Required identifiers
  prefix      = "myapp"
  environment = "dev"

  # Azure / AKS
  azurerm_subscription_id                  = data.azurerm_client_config.current.subscription_id
  azurerm_kubernetes_cluster_id            = module.aks.azurerm_kubernetes_cluster_id
  azurerm_kubernetes_cluster_oidc_issuer_url = module.aks.aks_oidc_issuer_url
  azurerm_kubernetes_workpool_vnet_id      = module.aks.aks_workpool_vnet_id

  # Resource group where ASO-managed resources should be created
  dis_resource_group_id = module.aks.dis_resource_group_id

  # Optional
  location         = "norwayeast"
  flux_release_tag = "latest"
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```
