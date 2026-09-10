resource "azapi_resource" "gateway_api" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "gateway-api"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        gateway-api = {
          force                  = false
          path                   = "./multitenancy/"
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
        }
      }
      ociRepository = {
        insecure = false
        repositoryRef = {
          tag = var.flux_release_tag
        }
        syncIntervalInSeconds = 300
        timeoutInSeconds      = 300
        url                   = "oci://altinncr.azurecr.io/manifests/infra/gateway-api"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
