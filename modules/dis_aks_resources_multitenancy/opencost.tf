resource "azurerm_user_assigned_identity" "opencost_metrics_reader" {
  count               = var.enable_opencost ? 1 : 0
  name                = "opencost-reader"
  resource_group_name = var.opencost_resource_group_name
  location            = "norwayeast"
}

resource "azurerm_federated_identity_credential" "opencost_metrics_reader" {
  count               = var.enable_opencost ? 1 : 0
  name                = "opencost-aks-federation"
  resource_group_name = azurerm_user_assigned_identity.opencost_metrics_reader[0].resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster_oidc_issuer_url
  subject             = "system:serviceaccount:opencost-system:opencost"
  parent_id           = azurerm_user_assigned_identity.opencost_metrics_reader[0].id
}

resource "azurerm_role_assignment" "opencost_metrics_reader" {
  count                            = var.enable_opencost ? 1 : 0
  principal_id                     = azurerm_user_assigned_identity.opencost_metrics_reader[0].principal_id
  scope                            = var.opencost_azure_monitoring_workspace_id
  role_definition_name             = "Monitoring Reader"
  skip_service_principal_aad_check = true
}

resource "azapi_resource" "opencost" {
  depends_on = [azurerm_user_assigned_identity.opencost_metrics_reader, azurerm_federated_identity_credential.opencost_metrics_reader, azurerm_role_assignment.opencost_metrics_reader]
  count      = var.enable_opencost ? 1 : 0
  type       = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name       = "opencost"
  parent_id  = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        opencost = {
          force = false
          path  = "./multitenancy"
          postBuild = {
            substitute = {
              AZURE_TENANT_ID : "${var.tenant_id}"
              OPENCOST_CLIENT_ID : "${azurerm_user_assigned_identity.opencost_metrics_reader[0].client_id}"
              AZURE_PROMETHEUS_ENDPOINT : "${var.opencost_prometheus_endpoint}"
              AKS_VNET_IPV4_CIDR : "${var.aks_vnet_ipv4_cidr}"
              AKS_VNET_IPV6_CIDR : "${var.aks_vnet_ipv6_cidr}"
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/opencost"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
