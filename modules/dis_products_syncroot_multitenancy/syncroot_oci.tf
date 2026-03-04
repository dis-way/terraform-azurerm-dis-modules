resource "azapi_resource" "syncroot" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = var.product
  parent_id = var.aks_cluster_id
  body = {
    properties = {
      kustomizations = {
        (var.product) = {
          force                  = false
          path                   = "./${var.environment}"
          prune                  = var.prune_enabled
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
        }
      }
      namespace = "product-${var.product}"
      ociRepository = {
        insecure = false
        repositoryRef = {
          tag = var.environment
        }
        syncIntervalInSeconds = 300
        timeoutInSeconds      = 300
        url                   = "oci://altinncr.azurecr.io/${var.product}/syncroot"
        useWorkloadIdentity   = true
      }
      scope                      = "namespace"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
