
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

data "azurerm_subscription" "primary" {}

resource "scaleway_instance_ip" "public_ip_db" {}

resource "azurerm_resource_group" "teleport-db" {
  name     = "teleport-demo-db-service"
  location = "North Europe"
}

resource "azurerm_linux_virtual_machine" "db-service" {
  name                = "teleport-db-service"
  resource_group_name = azurerm_resource_group.teleport-db.name
  size                = "Standard_F2"
  location            = azurerm_resource_group.teleport-db.location
  network_interface_ids = [
    azurerm_network_interface.db-service.id
  ]
  admin_username = "teleport"
  identity {
    type         = "UserAssigned"
    identity_ids = ["${azurerm_user_assigned_identity.db-service.id}"]
  }
  admin_ssh_key {
    username   = "teleport"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  user_data = base64encode(templatefile("db.userdata.sh.tftpl", {
    TELEPORT_DOMAIN          = "teleport.thinkahead.dev"
    TELEPORT_INVITE_TOKEN    = file("node-invite.tok")
    TELEPORT_DB_INVITE_TOKEN = file("db-invite.tok")
  }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "db-service" {
  name                = "db-service"
  location            = azurerm_resource_group.teleport-db.location
  resource_group_name = azurerm_resource_group.teleport-db.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.teleport.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db-service.id
  }
}

resource "azurerm_subnet" "teleport" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.teleport-db.name
  virtual_network_name = azurerm_virtual_network.teleport.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_virtual_network" "teleport" {
  name                = "teleport-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.teleport-db.location
  resource_group_name = azurerm_resource_group.teleport-db.name
}

resource "azurerm_public_ip" "db-service" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.teleport-db.name
  location            = azurerm_resource_group.teleport-db.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_user_assigned_identity" "db-service" {
  name                = "teleport-demo-db-service-identity"
  location            = azurerm_resource_group.teleport-db.location
  resource_group_name = azurerm_resource_group.teleport-db.name
}


resource "azurerm_role_assignment" "db-service" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = azurerm_role_definition.db-service.name
  principal_id         = azurerm_user_assigned_identity.db-service.principal_id
}

resource "azurerm_role_definition" "db-service" {
  name        = "teleport-demo-db-service-discovery-role"
  scope       = data.azurerm_subscription.primary.id
  description = "Allow database service VM to access databases"

  permissions {
    actions = [
      "Microsoft.DBforMySQL/servers/read",
      "Microsoft.DBforPostgreSQL/servers/read",
      "Microsoft.DBforMySQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "db-service-db-access" {
  name             = "allow-db-service"
  server_id        = local.db_credentials.server_id
  start_ip_address = azurerm_linux_virtual_machine.db-service.public_ip_address
  end_ip_address   = azurerm_linux_virtual_machine.db-service.public_ip_address
}

output "db-service-ssh" {
  value = "${azurerm_linux_virtual_machine.db-service.admin_username}@${azurerm_public_ip.db-service.ip_address}"
}

data "external" "current-user-ip" {
  program = ["bash", "${path.module}/ip.sh"]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "current-machine-db-access" {
  name             = "allow-terraform-machine"
  server_id        = local.db_credentials.server_id
  start_ip_address = data.external.current-user-ip.result.ip
  end_ip_address   = data.external.current-user-ip.result.ip
}

output "psql-create-role-script" {
  value = <<EOF
        # Log into database using an Azure AD token. Use a user in the '${nonsensitive(local.db_credentials.ad_group_name)}' group as configured in the database stack.
        az login
        export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query "[accessToken]" -o tsv)
        psql "host=${nonsensitive(local.db_credentials.hostname)} user=${nonsensitive(local.db_credentials.ad_group_name)} dbname=postgres sslmode=require"
        # Run within PSQL to add an ActiveDirectory user representing Teleport.
        SELECT * FROM pgaadauth_create_principal_with_oid('${var.teleport_internal_db_username}', '${azurerm_user_assigned_identity.db-service.client_id}', 'service', false, false);
        # Login to the database via Teleport
        tsh db connect --db-user=${var.teleport_internal_db_username} ${nonsensitive(local.db_credentials.name)} --db-name=${nonsensitive(local.db_credentials.database)}
        # NB You may need to restart Teleport on the database service machine (command, if accessible: ssh ${azurerm_linux_virtual_machine.db-service.admin_username}@${azurerm_linux_virtual_machine.db-service.public_ip_address})
    EOF
}

variable "teleport_internal_db_username" {
  type    = string
  default = "teleport"
}
