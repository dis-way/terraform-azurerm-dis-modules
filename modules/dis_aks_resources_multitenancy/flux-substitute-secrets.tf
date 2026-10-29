# Every postBuild.substitute variable of the flux configurations in this module, written
# one to one to the dis-system Key Vault as preparation for moving to
# postBuild.substituteFrom.
#
# Key Vault secret: <flux configuration name>-<variable in kebab-case>, for example
# traefik-aks-vnet-ipv4-cidr. Key Vault names allow only alphanumerics and dashes.
#
# The package's secrets layer maps each secret back to its variable with an ExternalSecret
# over dis-system-store, producing the Secret <flux configuration name>-substitute in
# platform-system, which the kustomizations read with:
#
#   postBuild = {
#     substituteFrom = [{ kind = "Secret", name = "traefik-substitute", optional = false }]
#   }
#
# Flux gives substitute precedence over substituteFrom, so a configuration can switch one
# variable at a time and drop it from substitute once the package reads it from the Secret.
# Reference: oci/grafana-public in gitops-manifests.
#
# external-secrets-operator is not included: its post-deploy substitutes create
# dis-system-store itself.
#
# The set of secrets depends only on which flux configurations exist and on the optional
# inputs below, never on values that can be unknown at plan time. azurerm does not accept
# "" as a secret value, so optional inputs left empty are skipped; Flux substitutes an
# unset variable with "" as well.
locals {
  flux_substitutes = merge(
    {
      "dis-identity-sync" = local.dis_identity_substitute
      "kyverno"           = local.kyverno_substitute
      "linkerd"           = merge(local.linkerd_substitute, local.linkerd_policies_substitute)
      "otel-collector"    = local.otel_collector_substitute
      "otel-operator"     = local.otel_operator_substitute
      "traefik"           = local.traefik_substitute
    },
    var.enable_dis_pgsql_operator ? { "dis-pgsql" = local.dis_pgsql_substitute } : {},
    var.enable_dis_vault_operator ? { "dis-vault" = local.dis_vault_substitute } : {},
    var.enable_flux_webhook_receiver ? { "flux-webhook-receiver" = local.flux_webhook_receiver_substitute } : {},
    var.enable_lets_encrypt_tls_issuer ? { "tls-issuer" = local.tls_issuer_substitute } : {},
    var.enable_opencost ? { "opencost" = local.opencost_substitute } : {},
    var.enable_valkey_operator ? { "valkey-operator" = local.valkey_operator_substitute } : {},
  )

  flux_substitute_optional = [
    "dis-vault-disvault-vpn-exit-node-subnet-id",
    "traefik-default-gateway-hostname",
  ]

  flux_substitute_secrets = {
    for name, value in merge([
      for config, vars in local.flux_substitutes : {
        for variable, value in vars : "${config}-${lower(replace(variable, "_", "-"))}" => value
      }
    ]...) : name => value
    if !contains(local.flux_substitute_optional, name) || value != ""
  }
}

resource "azurerm_key_vault_secret" "flux_substitute" {
  for_each     = toset(keys(local.flux_substitute_secrets))
  name         = each.value
  value        = local.flux_substitute_secrets[each.value]
  key_vault_id = var.dis_system_kv_id
}
