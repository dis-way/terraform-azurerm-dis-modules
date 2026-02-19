resource "azapi_resource" "traefik" {
  depends_on = [azapi_resource.linkerd]
  type       = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name       = "traefik"
  parent_id  = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        traefik = {
          force = false
          path  = "./adminservices/"
          postBuild = {
            substitute = {
              AKS_VNET_IPV4_CIDR : "${var.aks_vnet_ipv4_cidr}"
              AKS_VNET_IPV6_CIDR : "${var.aks_vnet_ipv6_cidr}"
              AKS_NODE_RG : "${var.aks_node_resource_group}"
              PUBLIC_IP_V4 : "${var.pip4_ip_address}"
              PUBLIC_IP_V6 : "${var.pip6_ip_address}"
            }
          }
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 300
          timeoutInSeconds       = 300
          wait                   = true
        }
      }
      namespace = "flux-system"
      ociRepository = {
        insecure = false
        repositoryRef = {
          tag = var.flux_release_tag
        }
        syncIntervalInSeconds = 300
        timeoutInSeconds      = 300
        url                   = "oci://altinncr.azurecr.io/manifests/infra/traefik"
        useWorkloadIdentity   = true
      }
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
