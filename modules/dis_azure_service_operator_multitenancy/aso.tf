resource "azapi_resource" "aso" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "azure-service-operator"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        aso = {
          force                  = false
          path                   = "./multitenancy/"
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
          postBuild = {
            substitute = {
              AZURE_TENANT_ID : "${azurerm_user_assigned_identity.aso_identity.tenant_id}"
              AZURE_CLIENT_ID : "${azurerm_user_assigned_identity.aso_identity.client_id}"
              AZURE_SUBSCRIPTION_ID : "${var.azurerm_subscription_id}"
              CRD_PATTERN : "${var.aso_crd_pattern}"
              AKS_VNET_IPV4_CIDR : "${var.aks_vnet_ipv4_cidr}"
              AKS_VNET_IPV6_CIDR : "${var.aks_vnet_ipv6_cidr}"
            }
          }
        }
      }
      ociRepository = {
        insecure = false
        repositoryRef = {
          tag = var.flux_release_tag
        }
        syncIntervalInSeconds = 300
        timeoutInSeconds      = 300
        url                   = "oci://altinncr.azurecr.io/manifests/infra/azure-service-operator"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
