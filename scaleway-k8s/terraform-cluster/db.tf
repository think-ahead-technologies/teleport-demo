
resource "azurerm_postgresql_flexible_server_firewall_rule" "kubernetes-lb" {
  name             = "allow-teleport-kubernetes-access"
  server_id        = local.db_credentials.server_id
  start_ip_address = scaleway_lb_ip.teleport.ip_address
  end_ip_address   = scaleway_lb_ip.teleport.ip_address
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "kubernetes-node" {
  name             = "allow-teleport-node-access"
  server_id        = local.db_credentials.server_id
  start_ip_address = scaleway_k8s_pool.teleport.nodes[0].public_ip
  end_ip_address   = scaleway_k8s_pool.teleport.nodes[0].public_ip
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
