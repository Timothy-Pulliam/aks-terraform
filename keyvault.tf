resource "random_id" "key_vault_name" {
  byte_length = 4
}

resource "azurerm_key_vault" "this" {
  # name must be globally unique
  name                        = "kv-${var.project}-${var.environment}-${random_id.key_vault_name.hex}"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

