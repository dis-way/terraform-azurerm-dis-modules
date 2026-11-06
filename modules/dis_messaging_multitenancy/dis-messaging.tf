locals {
  dis_messaging_substitute = {
    DISMSG_AZURE_SUBSCRIPTION_ID = provider::azurerm::parse_resource_id(azurerm_servicebus_namespace.messaging.id)["subscription_id"]
    DISMSG_AZURE_TENANT_ID       = var.tenant_id
    DISMSG_NAMESPACE_RESOURCE_ID = azurerm_servicebus_namespace.messaging.id
    DISMSG_ENV                   = var.environment
  }
}

# Deploys dis-messaging-operator to the cluster, the way dis_apim_operator_multitenancy
# deploys dis-apim. The operator creates queues through ASO and uses no Azure identity
# of its own at runtime yet. The inventory feature adds the client id of the operator
# identity to the substitutes later.
resource "azapi_resource" "dis_messaging_operator" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2025-04-01"
  name      = "dis-messaging"
  parent_id = var.kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        dis-messaging = {
          force = false
          path  = "./multitenancy/"
          postBuild = {
            substitute = local.dis_messaging_substitute
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/dis-messaging"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
