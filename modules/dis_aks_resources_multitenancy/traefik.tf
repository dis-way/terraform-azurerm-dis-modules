resource "azapi_resource" "cert_manager" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "traefik"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = {
        traefik = {
          force                  = false
          path                   = "./multitenancy/"
          postBuild = {
            substitute = {
              AKS_VNET_IPV4_CIDR : "${var.aks_vnet_ipv4_cidr}"
              AKS_VNET_IPV6_CIDR : "${var.aks_vnet_ipv6_cidr}"
              DEFAULT_GATEWAY_HOSTNAME : "${var.default_gateway_hostname}}"
              AKS_NODE_RG : "${var.aks_node_resource_group}"
              PUBLIC_IP_V4 : "${var.aks_public_ipv4_address}"
              PUBLIC_IP_V6 : "${var.aks_public_ipv6_address}"
              # EXTERNAL_TRAFFIC_POLICY: Cluster (Local is default in traefik oci)
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
        url                   = "oci://altinncr.azurecr.io/manifests/infra/traefik"
        useWorkloadIdentity   = true
      }
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
