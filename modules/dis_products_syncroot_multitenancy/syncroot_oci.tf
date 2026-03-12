resource "random_string" "random_postfix" {
  keepers = {
    product = var.product
    env     = var.environment
    cluster = var.aks_cluster_id
  }
  length  = 4
  numeric = true
  upper   = false
  lower   = true
  special = false
}

resource "azapi_resource" "syncroot" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "${var.product}-${random_string.random_postfix.result}"
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
