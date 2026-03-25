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

locals {
  # Serverless: GP_S_Gen5_<max_cores>  |  DTU Standard: e.g. S2
  sku_name = var.serverless ? "GP_S_Gen5_${var.max_cores}" : var.dtu_sku

  # auto_pause_delay_in_minutes and min_capacity are serverless-only; null omits them for DTU
  auto_pause_delay_in_minutes = var.serverless ? (var.enable_autopause ? var.autopause_after_mins : -1) : null
  min_capacity                = var.serverless ? var.min_cores : null

  # Zone redundancy and Zone storage are not supported on Standard DTU tier
  storage_account_type = var.serverless ? "Zone" : "Local"
  zone_redundant       = var.serverless
}

resource "azurerm_mssql_database" "azsql" {
  name      = var.database_name
  server_id = azurerm_mssql_server.azsql.id

  sku_name                    = local.sku_name
  auto_pause_delay_in_minutes = local.auto_pause_delay_in_minutes
  min_capacity                = local.min_capacity
  storage_account_type        = local.storage_account_type
  zone_redundant              = local.zone_redundant
  tags                        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
