locals {
  lakmus_substitute = {
    AZURE_SUBSCRIPTION_ID              = var.subscription_id
    LAKMUS_WORKLOAD_IDENTITY_CLIENT_ID = var.lakmus_client_id
  }
}

resource "azapi_resource" "lakmus" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2025-04-01"
  name      = "lakmus"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        lakmus = {
          force = false
          path  = "./"
          postBuild = {
            substitute = local.lakmus_substitute
          }
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 3600
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/lakmus"
        useWorkloadIdentity   = true
      }
      namespace                  = "flux-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
