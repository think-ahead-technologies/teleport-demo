
resource "azurerm_postgresql_flexible_server_firewall_rule" "teleport" {
  name             = "allow-teleport-access"
  server_id        = local.db_credentials.server_id
  start_ip_address = scaleway_instance_ip.temp_tag_ip_1.address
  end_ip_address   = scaleway_instance_ip.temp_tag_ip_1.address
}

locals {
  db_credentials = jsondecode(base64decode(data.scaleway_secret_version.db-credentials.data))
}

data "scaleway_secret" "db-credentials" {
  name = "credentials"
  path = "/teleport-demo/database"
}

data "scaleway_secret_version" "db-credentials" {
  secret_id = data.scaleway_secret.db-credentials.secret_id
  revision  = "latest"
}
