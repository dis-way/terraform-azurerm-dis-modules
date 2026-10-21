# Every postBuild.substitute variable of the flux configurations in this module, written
# one to one to the dis-system Key Vault as preparation for moving to
# postBuild.substituteFrom.
#
# Key Vault secret: <flux configuration name>-<variable in kebab-case>, for example
# traefik-aks-vnet-ipv4-cidr. Key Vault names allow only alphanumerics and dashes.
#
# The package's secrets layer maps each secret back to its variable with an ExternalSecret
# over dis-system-store, producing the Secret <flux configuration name>-substitute in
# flux-system, which the kustomizations read with:
#
#   postBuild = {
#     substituteFrom = [{ kind = "Secret", name = "traefik-substitute", optional = false }]
#   }
#
# Flux gives substitute precedence over substituteFrom, so a configuration can switch one
# variable at a time and drop it from substitute once the package reads it from the Secret.
# Reference: oci/grafana-public in gitops-manifests.
#
# external-secrets-operator is not included: its substitutes create dis-system-store itself.
#
# The set of secrets depends only on which flux configurations exist and on the optional
# inputs below, never on values that can be unknown at plan time. azurerm does not accept
# "" as a secret value, so optional inputs left empty are skipped; Flux substitutes an
# unset variable with "" as well.
locals {
  flux_substitutes = merge(
    {
      "container-runtime-aks-config" = local.container_runtime_aks_config_teams_rbac_substitute
      "lakmus"                       = local.lakmus_substitute
      "linkerd"                      = local.linkerd_substitute
      "otel-collector"               = local.otel_collector_substitute
      "traefik"                      = local.traefik_substitute
    },
    var.enable_cert_manager_tls_issuer ? { "tls-issuer" = local.tls_issuer_substitute } : {},
    var.enable_dis_identity_operator ? { "dis-identity" = local.dis_identity_substitute } : {},
    var.enable_dis_vault_operator ? { "dis-vault" = local.dis_vault_substitute } : {},
    var.enable_grafana_operator ? {
      "grafana-operator" = merge(
        local.grafana_operator_substitute,
        local.grafana_operator_post_deploy_substitute,
        local.grafana_redirect_substitute,
        local.grafana_manifests_substitute,
      )
    } : {},
  )

  flux_substitute_optional = [
    "dis-vault-disvault-vpn-exit-node-subnet-id",
    "grafana-operator-grafana-admin-apikey",
    "traefik-traefik-internal-ip-v4",
    "traefik-traefik-internal-ip-v6",
    "traefik-traefik-internal-subnet",
  ]

  flux_substitute_secrets = {
    for name, value in merge([
      for config, vars in local.flux_substitutes : {
        for variable, value in vars : "${config}-${lower(replace(variable, "_", "-"))}" => value
      }
    ]...) : name => value
    if !contains(local.flux_substitute_optional, name) || nonsensitive(value != "")
  }
}

resource "azurerm_key_vault_secret" "flux_substitute" {
  for_each     = toset(keys(local.flux_substitute_secrets))
  name         = each.value
  value        = local.flux_substitute_secrets[each.value]
  key_vault_id = var.dis_system_kv_id
}
