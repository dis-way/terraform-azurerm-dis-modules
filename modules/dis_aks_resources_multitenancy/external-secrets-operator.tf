# Read by the package's multitenancy/secrets layer from the dis-system Key Vault into
# CENTRAL_ACCESSTOKEN_KV_URL, which multitenancy/central-accesstoken reads through
# substituteFrom. Its own resource, not part of flux-substitute-secrets.tf, so
# external_secrets_operator depends on this secret only.
resource "azurerm_key_vault_secret" "central_accesstoken_kv_url" {
  count        = var.enable_central_accesstoken ? 1 : 0
  name         = "external-secrets-operator-central-accesstoken-kv-url"
  value        = var.central_accesstoken_kv_uri
  key_vault_id = var.dis_system_kv_id
}

# Read by the package's multitenancy/flux-dispatch-app and flux-dispatch-token/secrets
# layers. The App private key is not written here: the dis_system_kv module's write-only
# secrets input writes it as flux-dispatch-github-app-private-key, so it stays out of
# Terraform state.
resource "azurerm_key_vault_secret" "flux_dispatch" {
  for_each     = local.flux_dispatch_secrets
  name         = each.key
  value        = each.value
  key_vault_id = var.dis_system_kv_id
}

locals {
  # Short keys: AKS names each Kustomization <configuration>-<key>, and the two together
  # may be at most 62 characters, leaving 37 after "external-secrets-operator".
  external_secrets_operator_central_accesstoken_kustomizations = {
    # Writes the external-secrets-operator-vars Secret in platform-system from
    # dis-system-store. wait = true keeps central-accesstoken from applying before the
    # Secret exists.
    secrets = {
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
    central-accesstoken = {
      dependsOn = ["secrets"]
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

  flux_dispatch_secrets = merge(
    length(var.flux_dispatch_tokens) == 0 ? {} : {
      "flux-dispatch-github-app-id"              = var.flux_dispatch_github_app_id
      "flux-dispatch-github-app-installation-id" = var.flux_dispatch_github_app_installation_id
    },
    [for name, token in var.flux_dispatch_tokens : {
      "flux-dispatch-${name}-github-repository-name" = token.github_repository_name
      "flux-dispatch-${name}-token-namespace"        = token.token_namespace
      "flux-dispatch-${name}-token-secret-name"      = token.token_secret_name
    }]...
  )

  # flux-dispatch-app once, for the shared GitHub App, and two kustomizations per mapping.
  external_secrets_operator_flux_dispatch_kustomizations = merge(
    {
      # Writes the flux-dispatch-github-app Secret in platform-system. wait = false: its
      # ExternalSecret stays NotReady until the private key is in the vault.
      flux-dispatch-app = {
        dependsOn              = ["external-secrets-operator-post-deploy"]
        force                  = false
        path                   = "./multitenancy/flux-dispatch-app/"
        prune                  = false
        retryIntervalInSeconds = 300
        syncIntervalInSeconds  = 3600
        timeoutInSeconds       = 300
        wait                   = false
      }
    },
    [for name in keys(var.flux_dispatch_tokens) : {
      # Writes the flux-dispatch-<name>-vars Secret in platform-system.
      "flux-dispatch-${name}-secrets" = {
        dependsOn = ["external-secrets-operator-post-deploy"]
        force     = false
        path      = "./multitenancy/flux-dispatch-token/secrets/"
        postBuild = {
          substitute = {
            FLUX_DISPATCH_NAME = name
          }
        }
        prune                  = false
        retryIntervalInSeconds = 300
        syncIntervalInSeconds  = 3600
        timeoutInSeconds       = 300
        wait                   = true
      }
      # Renews the token and copies it to the product namespace. wait = false for the
      # same reason as flux-dispatch-app. prune = true: removing the mapping deletes the
      # token objects and the destination Secret.
      "flux-dispatch-${name}" = {
        dependsOn = ["flux-dispatch-app", "flux-dispatch-${name}-secrets"]
        force     = false
        path      = "./multitenancy/flux-dispatch-token/"
        postBuild = {
          substitute = {
            FLUX_DISPATCH_NAME = name
          }
          substituteFrom = [
            {
              kind     = "Secret"
              name     = "flux-dispatch-${name}-vars"
              optional = false
            }
          ]
        }
        prune                  = true
        retryIntervalInSeconds = 300
        syncIntervalInSeconds  = 3600
        timeoutInSeconds       = 300
        wait                   = false
      }
    }]...
  )
}

resource "azapi_resource" "external_secrets_operator" {
  depends_on = [
    azapi_resource.linkerd,
    # ApplicationIdentity in multitenancy/central-accesstoken.
    azapi_resource.dis_identity_operator,
    # Read by multitenancy/secrets.
    azurerm_key_vault_secret.central_accesstoken_kv_url,
    # Read by multitenancy/flux-dispatch-app and flux-dispatch-token/secrets.
    azurerm_key_vault_secret.flux_dispatch,
  ]
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2024-11-01"
  name      = "external-secrets-operator"
  parent_id = var.azurerm_kubernetes_cluster_id
  body = {
    properties = {
      # The central access token and flux dispatch kustomizations are filtered with a for
      # expression, not a conditional: both results of a conditional must have the same
      # object type, and {} lacks their attributes.
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
        }, {
        for name, kustomization in local.external_secrets_operator_central_accesstoken_kustomizations :
        name => kustomization if var.enable_central_accesstoken
        }, {
        for name, kustomization in local.external_secrets_operator_flux_dispatch_kustomizations :
        name => kustomization if length(var.flux_dispatch_tokens) > 0
      })
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
