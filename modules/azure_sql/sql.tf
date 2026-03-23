resource "azurerm_user_assigned_identity" "azsql" {
  name                = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-sql-uami"
  resource_group_name = azurerm_resource_group.azsql.name
  location            = azurerm_resource_group.azsql.location
  tags                = var.tags
}

resource "azurerm_mssql_server" "azsql" {
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
    login_username              = azurerm_user_assigned_identity.azsql.name
    object_id                   = azurerm_user_assigned_identity.azsql.principal_id
    azuread_authentication_only = true
  }
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
}

resource "azurerm_mssql_database" "azsql" {
  name      = "${var.prefix}-${var.environment}-${random_string.db_name_suffix.result}-serverless-db"
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

