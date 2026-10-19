# Routes https://flux-webhook.<default_gateway_hostname>/hook/... from the flux-webhook listener
# to the Flux notification-controller, so a publishing workflow can ask Flux, through the DIS
# edge, to reconcile a Receiver right after it pushes an artifact (RFC 0017).
resource "azapi_resource" "flux_webhook_receiver" {
  depends_on = [azapi_resource.traefik]
  count      = var.enable_flux_webhook_receiver ? 1 : 0
  type       = "Microsoft.KubernetesConfiguration/fluxConfigurations@2025-04-01"
  name       = "flux-webhook-receiver"
  parent_id  = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        flux-webhook-receiver = {
          force = false
          path  = "./multitenancy/"
          postBuild = {
            substitute = {
              DEFAULT_GATEWAY_HOSTNAME : "${var.default_gateway_hostname}"
            }
          }
          prune                  = true
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/flux-webhook-receiver"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
