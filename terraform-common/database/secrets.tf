
data "scaleway_secret" "db-admin-password" {
  name = "admin-password"
  path = "/teleport-demo/database"
}

data "scaleway_secret_version" "db-admin-password" {
  secret_id = data.scaleway_secret.db-admin-password.secret_id
  revision  = "latest"
}

locals {
  database_hostname = "${azurerm_postgresql_flexible_server.teleport.name}.postgres.database.azure.com"
  db_access_string  = "postgres://${azurerm_postgresql_flexible_server.teleport.administrator_login}:${azurerm_postgresql_flexible_server.teleport.administrator_password}@${local.database_hostname}:5432/${azurerm_postgresql_flexible_server_database.teleport.name}?sslmode=require"
}

resource "scaleway_secret" "db-credentials" {
  name = "credentials"
  path = "/teleport-demo/database"
}

resource "scaleway_secret_version" "db-credentials" {
  secret_id = scaleway_secret.db-credentials.id
  data = jsonencode({
    server_id     = azurerm_postgresql_flexible_server.teleport.id
    hostname      = "${azurerm_postgresql_flexible_server.teleport.name}.postgres.database.azure.com"
    username      = "psqladmin"
    password      = base64decode(data.scaleway_secret_version.db-admin-password.data)
    access_string = local.db_access_string
  })
}
