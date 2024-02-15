resource "azurerm_private_dns_zone" "db" {
  name                = "${var.project}-${var.environment}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

# Generate random password for pgadmin account
resource "random_password" "pgadmin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "pgadmin_password" {
  name         = "pgadmin-password"
  value        = random_password.pgadmin_password.result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "db-${var.project}-${var.environment}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  version                = var.postgres_version
  delegated_subnet_id    = lookup(module.vnet.vnet_subnets_name_id, "snet-db")
  private_dns_zone_id    = azurerm_private_dns_zone.db.id
  administrator_login    = "pgadmin"
  administrator_password = azurerm_key_vault_secret.pgadmin_password.value
  zone                   = "1"

  # backups
  backup_retention_days        = 14
  geo_redundant_backup_enabled = true

  storage_mb = var.db_storage_mb

  sku_name = var.db_sku

  tags = local.tags
}

resource "azurerm_postgresql_flexible_server_configuration" "password_encryption" {
  name      = "password_encryption"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "SCRAM-SHA-256"
}

resource "azurerm_postgresql_flexible_server_configuration" "accepted_password_auth_method" {
  name      = "azure.accepted_password_auth_method"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "SCRAM-SHA-256"
}


