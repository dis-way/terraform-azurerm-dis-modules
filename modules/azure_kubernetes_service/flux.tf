moved {
  from = azurerm_kubernetes_cluster_extension.flux
  to   = azurerm_kubernetes_cluster_extension.flux[0]
}

resource "azurerm_kubernetes_cluster_extension" "flux" {
  count          = var.enable_flux ? 1 : 0
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.aks.id
  extension_type = "microsoft.flux"
  configuration_settings = {
    "useKubeletIdentity"      = "true"
    "autoUpgradeMinorVersion" = "true"
    "multiTenancy.enforce"    = var.enable_multi_tenancy
  }

  # Azure upgrades the extension, because no version is set here. An operator can
  # pin a version with `az k8s-extension update --version`, for example to hold
  # back an upgrade. In azurerm, a change to version or
  # release_train forces a new extension, which reinstalls Flux on the cluster.
  # Terraform therefore ignores both.
  lifecycle {
    ignore_changes = [version, release_train]
  }
}
