resource "azapi_resource" "kube_state_metrics" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "kube-state-metrics"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        kube-state-metrics = {
          force                  = false
          path                   = "./multitenancy/"
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = false
        }
      }
      ociRepository = {
        insecure = false
        repositoryRef = {
          tag = var.flux_release_tag
        }
        syncIntervalInSeconds = 300
        timeoutInSeconds      = 300
        url                   = "oci://altinncr.azurecr.io/manifests/infra/kube-state-metrics"
        useWorkloadIdentity   = true
      }
      namespace                  = "flux-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = false
      sourceKind                 = "OCIRepository"
    }
  }
}
