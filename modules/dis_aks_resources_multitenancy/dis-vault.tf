resource "azapi_resource" "dis_vault_operator" {
  depends_on = [azapi_resource.cert_manager]
  count      = var.enable_dis_vault_operator ? 1 : 0
  type       = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name       = "dis-vault"
  parent_id  = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        dis-vault = {
          force = false
          path  = "./multitenancy/"
          postBuild = {
            # DISVAULT_VPN_EXIT_NODE_SUBNET_ID is optional. Azure's fluxConfigurations ARM API
            # normalizes an empty-string substitute value to null, which Flux's Kustomization CRD
            # then rejects ("must be of type string"). Only emit the key when it is actually set.
            substitute = merge(
              {
                DISVAULT_AZURE_SUBSCRIPTION_ID = var.subscription_id
                DISVAULT_RESOURCE_GROUP        = var.dis_resource_group_name
                DISVAULT_AZURE_TENANT_ID       = var.tenant_id
                DISVAULT_LOCATION              = var.dis_vault_location
                DISVAULT_ENV                   = var.dis_vault_environment
                DISVAULT_AKS_SUBNET_IDS        = var.dis_vault_aks_subnet_ids
              },
              trimspace(var.dis_vault_vpn_exit_node_subnet_id) != "" ? {
                DISVAULT_VPN_EXIT_NODE_SUBNET_ID = var.dis_vault_vpn_exit_node_subnet_id
              } : {}
            )
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/dis-vault"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
