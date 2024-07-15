resource "azurerm_resource_group" "teleport" {
  name     = "teleport-demo"
  location = "North Europe"
}

resource "azurerm_postgresql_flexible_server" "teleport" {
  name                = "think-ahead-teleport-demo-db"
  location            = azurerm_resource_group.teleport.location
  resource_group_name = azurerm_resource_group.teleport.name
  zone                = "2"

  sku_name                     = "GP_Standard_D4s_v3"
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  administrator_login          = "psqladmin"
  administrator_password       = base64decode(data.scaleway_secret_version.db-admin-password.data)
  version                      = "12"

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = var.ARM_TENANT_ID
  }
}

data "azurerm_client_config" "current" {}

# Any Entra ID user within this group can do admin tasks on the database.
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "teleport" {
  server_name         = azurerm_postgresql_flexible_server.teleport.name
  resource_group_name = azurerm_resource_group.teleport.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = "fa0bb52e-1e2b-40ac-baf5-7a218cd6eac7"
  principal_name      = "access"
  principal_type      = "Group"
}

resource "azurerm_postgresql_flexible_server_database" "teleport" {
  name      = "teleport"
  server_id = azurerm_postgresql_flexible_server.teleport.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
