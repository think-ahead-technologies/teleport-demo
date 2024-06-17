resource "azurerm_resource_group" "teleport" {
  name     = "api-rg-pro"
  location = "North Europe"
  # West Europe apparently doesn't work:
  #   https://sitecore.stackexchange.com/questions/9075/when-attempting-to-deploy-i-get-restricted-from-provisioning-in-this-region
  # Error: creating Flexible Server (Subscription: "77e05782-a2f5-457f-8a77-e00e5826a2dd"
  # │ Resource Group Name: "api-rg-pro"
  # │ Flexible Server Name: "think-ahead-teleport-demo-db"): polling after Create: polling failed: the Azure API returned the following error:
  # │
  # │ Status: "RegionIsOfferRestricted"
  # │ Code: ""
  # │ Message: "Subscriptions are restricted from provisioning in this region. Please choose a different region. For exceptions to this rule please open a support request with Issue type of 'Service and subscription limits'. See https://review.learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-request-quota-increase for more details."
  # │ Activity Id: ""
}


# terraform import azurerm_postgresql_flexible_server.teleport /subscriptions/$TF_VAR_ARM_SUBSCRIPTION_ID/resourceGroups/api-rg-pro/providers/Microsoft.DBforPostgreSQL/flexibleServers/think-ahead-teleport-demo-db


# TODO put the database in this, and lock it down to the Scaleway server/VPC IP(s).
# resource "azurerm_virtual_network" "teleport" {
#   name                = "teleport-network"
#   resource_group_name = azurerm_resource_group.teleport.name
#   location            = azurerm_resource_group.teleport.location
#   address_space       = ["10.0.0.0/16"]
# }

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
}

resource "azurerm_postgresql_flexible_server_database" "teleport" {
  name      = "teleport"
  server_id = azurerm_postgresql_flexible_server.teleport.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "teleport" {
  name             = "allow-teleport-access"
  server_id        = azurerm_postgresql_flexible_server.teleport.id
  start_ip_address = scaleway_instance_ip.temp_tag_ip_1.address
  end_ip_address   = scaleway_instance_ip.temp_tag_ip_1.address
}


locals {
  database_hostname = "${azurerm_postgresql_flexible_server.teleport.name}.postgres.database.azure.com"
  db_access_string  = "postgres://${azurerm_postgresql_flexible_server.teleport.administrator_login}:${azurerm_postgresql_flexible_server.teleport.administrator_password}@${local.database_hostname}:5432/${azurerm_postgresql_flexible_server_database.teleport.name}?sslmode=require"
}

data "scaleway_secret" "db-admin-password" {
  name = "admin-password"
  path = "/teleport-demo/database"
}

data "scaleway_secret_version" "db-admin-password" {
  secret_id = data.scaleway_secret.db-admin-password.secret_id
  revision  = "latest"
}
