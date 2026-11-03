locals {
  # Read by the package's multitenancy/secrets layer from the dis-system Key Vault, see
  # flux-substitute-secrets.tf, and substituted into multitenancy/central-accesstoken
  # through substituteFrom.
  external_secrets_operator_substitute = {
    CENTRAL_ACCESSTOKEN_KV_URL = var.central_accesstoken_kv_uri
  }

  external_secrets_operator_central_accesstoken_kustomizations = {
    # Writes the external-secrets-operator-vars Secret in platform-system from
    # dis-system-store. wait = true keeps central-accesstoken from applying before the
    # Secret exists.
    external-secrets-operator-secrets = {
      dependsOn              = ["external-secrets-operator-post-deploy"]
      force                  = false
      path                   = "./multitenancy/secrets/"
      prune                  = false
      retryIntervalInSeconds = 300
      syncIntervalInSeconds  = 3600
      timeoutInSeconds       = 300
      wait                   = true
    }
    # ApplicationIdentity central-accesstoken-eso and the central-accesstoken-store
    # ClusterSecretStore. wait = false: the store stays NotReady until the identity is
    # granted read access to the token secret, which happens outside this module.
    external-secrets-operator-central-accesstoken = {
      dependsOn = ["external-secrets-operator-secrets"]
      force     = false
      path      = "./multitenancy/central-accesstoken/"
      postBuild = {
        substituteFrom = [
          {
            kind     = "Secret"
            name     = "external-secrets-operator-vars"
            optional = false
          }
        ]
      }
      prune                  = false
      retryIntervalInSeconds = 300
      syncIntervalInSeconds  = 3600
      timeoutInSeconds       = 300
      wait                   = false
    }
  }
}

resource "azapi_resource" "external_secrets_operator" {
  depends_on = [
    azapi_resource.linkerd,
    # ApplicationIdentity in multitenancy/central-accesstoken.
    azapi_resource.dis_identity_operator,
    # external-secrets-operator-central-accesstoken-kv-url read by multitenancy/secrets.
    azurerm_key_vault_secret.flux_substitute,
  ]
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "external-secrets-operator"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      kustomizations = merge({
        external-secrets-operator = {
          force = false
          path  = "./multitenancy/"
          postBuild = {
            substitute = {
              AKS_VNET_IPV4_CIDR : "${var.aks_vnet_ipv4_cidr}"
              AKS_VNET_IPV6_CIDR : "${var.aks_vnet_ipv6_cidr}"
            }
          }
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 3600
          timeoutInSeconds       = 300
          wait                   = true
        }
        external-secrets-operator-post-deploy = {
          dependsOn = ["external-secrets-operator"]
          force     = false
          path      = "./multitenancy/post-deploy/"
          postBuild = {
            substitute = {
              DIS_SYSTEM_KV_ESO_CLIENT_ID = "${var.dis_system_kv_client_id}"
              DIS_SYSTEM_KV_URL           = "${var.dis_system_kv_uri}"
              TENANT_ID                   = "${var.tenant_id}"
            }
          }
          prune                  = false
          retryIntervalInSeconds = 300
          syncIntervalInSeconds  = 3600
          timeoutInSeconds       = 300
          wait                   = false
        }
      }, var.enable_central_accesstoken ? local.external_secrets_operator_central_accesstoken_kustomizations : {})
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
      namespace                  = "platform-system"
      reconciliationWaitDuration = "PT5M"
      waitForReconciliation      = true
      sourceKind                 = "OCIRepository"
    }
  }
}
