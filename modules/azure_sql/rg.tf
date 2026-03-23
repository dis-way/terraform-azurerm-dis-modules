resource "azurerm_resource_group" "azsql" {
  name     = "${var.prefix}-${var.environment}-azsql-rg"
  location = var.location
  tags     = var.tags
}
