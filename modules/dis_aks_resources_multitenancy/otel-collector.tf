resource "azapi_resource" "otel_collector" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "otel-collector"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        otel-collector = {
          force = false
          path  = "./multitenancy"
          postBuild = {
            substitute = {
              KV_URI : "${var.otel_kv_uri}"
              CLIENT_ID : "${var.otel_client_id}"
              TENANT_ID : "${var.otel_tenant_id}"
              AMW_WRITE_ENDPOINT : "${var.otel_amw_write_endpoint}"
            }
          }
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/otel-collector"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
