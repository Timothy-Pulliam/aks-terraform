resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location # az account list-locations --query '[].displayName'
  tags     = local.tags
}
