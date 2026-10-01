resource "azapi_resource" "eso" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "external-secrets-operator"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        external-secrets-operator = {
          force                  = false
          path                   = "./base/"
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
        }
        external-secrets-operator-post-deploy = {
          dependsOn = ["external-secrets-operator"]
          force     = false
          path      = "./adminservices/post-deploy/"
          postBuild = {
            substitute = {
              DIS_SYSTEM_KV_ESO_CLIENT_ID = "${var.dis_system_kv_client_id}"
              DIS_SYSTEM_KV_URL           = "${var.dis_system_kv_uri}"
              TENANT_ID                   = "${var.tenant_id}"
            }
          }
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/external-secrets-operator"
        useWorkloadIdentity   = true
      }
      namespace                  = "flux-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
