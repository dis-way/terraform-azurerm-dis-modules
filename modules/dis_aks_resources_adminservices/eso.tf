locals {
  # The post-deploy layer creates the dis-system-store SecretStore in flux-system, so only
  # deploy it once the dis-system Key Vault exists and its identity has been passed in.
  eso_post_deploy_kustomizations = {
    for name, kustomization in {
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
    } : name => kustomization if var.dis_system_kv_client_id != ""
  }
}

resource "azapi_resource" "eso" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "external-secrets-operator"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = merge({
        external-secrets-operator = {
          force                  = false
          path                   = "./base/"
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
        }
      }, local.eso_post_deploy_kustomizations)
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
