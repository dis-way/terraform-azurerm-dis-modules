resource "azapi_resource" "kyverno_policies" {
  depends_on = [azapi_resource.kyverno]
  type       = "Microsoft.KubernetesConfiguration/fluxConfigurations@2025-04-01"
  name       = "kyverno-policies"
  parent_id  = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        kyverno-policies = {
          force                  = false
          path                   = "./multitenancy/"
          prune                  = true
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/kyverno-policies"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
