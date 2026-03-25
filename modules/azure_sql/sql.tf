resource "azurerm_user_assigned_identity" "azsql" {
  name                = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-sql-uami"
  resource_group_name = azurerm_resource_group.azsql.name
  location            = azurerm_resource_group.azsql.location
  tags                = var.tags
}

resource "azuread_group_member" "azsql_uami_admin" {
  group_object_id  = var.database_admin_group_object_id
  member_object_id = azurerm_user_assigned_identity.azsql.principal_id
}

resource "azurerm_mssql_server" "azsql" {
  depends_on                           = [azuread_group_member.azsql_uami_admin]
  name                                 = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-server"
  resource_group_name                  = azurerm_resource_group.azsql.name
  location                             = azurerm_resource_group.azsql.location
  version                              = var.server_version
  minimum_tls_version                  = "1.2"
  public_network_access_enabled        = false
  outbound_network_restriction_enabled = true
  tags                                 = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.azsql.id]
  }

  azuread_administrator {
    login_username              = var.database_admin_group_name
    object_id                   = var.database_admin_group_object_id
    azuread_authentication_only = true
  }

  primary_user_assigned_identity_id = azurerm_user_assigned_identity.azsql.id
}

resource "azurerm_private_endpoint" "azsql" {
  name                = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-sql-pe"
  resource_group_name = azurerm_resource_group.azsql.name
  location            = azurerm_resource_group.azsql.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.azsql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "sql-dns-zone-group"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }
}

resource "azurerm_mssql_database" "azsql" {
  name      = var.database_name
  server_id = azurerm_mssql_server.azsql.id

  # Serverless SKU name:
  # GP_S_Gen5_* for General Purpose, Gen5 hardware, Serverless tier
  sku_name = "GP_S_Gen5_${var.max_cores}"

  auto_pause_delay_in_minutes = var.enable_autopause ? var.autopause_after_mins : -1
  min_capacity                = var.min_cores
  storage_account_type        = "Zone"
  zone_redundant              = true
  tags                        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
