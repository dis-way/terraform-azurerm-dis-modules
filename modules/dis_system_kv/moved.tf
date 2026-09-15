# One-shot state migration: the individually declared secrets became a single for_each
# resource keyed by Key Vault secret name. Without these the old and new addresses are
# unrelated graph nodes, so Terraform would destroy and create the same Azure secret
# name concurrently. Safe to delete once this has been applied in every environment.

moved {
  from = azurerm_key_vault_secret.tailscale_preshare_key
  to   = azurerm_key_vault_secret.this["headscale-preauth-key"]
}

moved {
  from = azurerm_key_vault_secret.tenant_id
  to   = azurerm_key_vault_secret.this["tenant-id"]
}

moved {
  from = azurerm_key_vault_secret.aks_name
  to   = azurerm_key_vault_secret.this["aks-name"]
}

moved {
  from = azurerm_key_vault_secret.advertise_routes
  to   = azurerm_key_vault_secret.this["ts-advertised-routes"]
}

moved {
  from = azurerm_key_vault_secret.aks_vnet_ipv4_cidr
  to   = azurerm_key_vault_secret.this["aks-vnet-ipv4-cidr"]
}

moved {
  from = azurerm_key_vault_secret.aks_vnet_ipv6_cidr
  to   = azurerm_key_vault_secret.this["aks-vnet-ipv6-cidr"]
}
