resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location # az account list-locations --query '[].displayName'
  tags     = local.tags
}

resource "azurerm_management_lock" "resource-group-level" {
  count      = var.lock_resource_group ? 1 : 0
  name       = "resource-group-level"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Locked to avoid accidental deletion"
}
