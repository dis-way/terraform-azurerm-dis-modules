### Minimal usage example
This module provisions the Azure resources needed for running Azure Service Operator (ASO) in AKS using workload identity, and configures ASO deployment via an AKS Flux configuration (OCI source).

It targets the **adminservices** platform layout — the `base` ASO manifests deployed through the `flux-system` namespace (the counterpart to `dis_azure_service_operator_multitenancy`, which uses the `multitenancy` overlay in `platform-system`). The ASO managed identity is granted a role that includes `Microsoft.DBforPostgreSQL/flexibleServers/configurations/write`, so the operator can manage flexible server configurations.

```hcl
module "dis_azure_service_operator" {
  source = "./modules/dis_azure_service_operator_adminservices"

  # Required identifiers
  prefix      = "admin"
  environment = "test"

  # Azure / AKS
  azurerm_subscription_id                    = data.azurerm_client_config.current.subscription_id
  azurerm_kubernetes_cluster_id              = module.aks.azurerm_kubernetes_cluster_id
  azurerm_kubernetes_cluster_oidc_issuer_url = module.aks.aks_oidc_issuer_url
  azurerm_kubernetes_workpool_vnet_id        = module.aks.aks_vnet_id

  # Resource group where ASO-managed resources should be created
  dis_resource_group_id = module.aks.dis_resource_group_id

  # Optional
  location         = "norwayeast"
  flux_release_tag = "latest"
  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
```
