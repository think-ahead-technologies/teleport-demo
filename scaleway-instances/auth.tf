
resource "scaleway_instance_ip" "temp_auth_ip_1" {}

resource "scaleway_instance_user_data" "auth" {
  server_id = scaleway_instance_server.teleport-auth-1.id
  key       = "cloud-init"
  value = templatefile("vm.userdata.sh.tftpl", {
    TELEPORT_EDITION = var.TELEPORT_EDITION
    TELEPORT_VERSION = var.TELEPORT_VERSION
  })
}

resource "scaleway_instance_server" "teleport-auth-1" {
  type  = "DEV1-L"
  image = "ubuntu_jammy"
  name  = "scw-teleport-demo-auth"
  tags  = var.TAGS
  ip_id = scaleway_instance_ip.temp_auth_ip_1.id
}

data "scaleway_secret" "ca-cert" {
  name = "cert"
  path = "/teleport-demo/instances/ca"
}

data "scaleway_secret_version" "ca-cert" {
  secret_id = data.scaleway_secret.ca-cert.id
  revision  = "latest"
}

data "scaleway_secret" "license" {
  name = "teleport-license"
  path = "/teleport-demo/license"
}

data "scaleway_secret_version" "license" {
  secret_id = data.scaleway_secret.license.id
  revision  = "latest"
}

resource "null_resource" "copy-teleport-conf-auth" {
  connection {
    host        = scaleway_instance_server.teleport-auth-1.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.SSH_KEYFILE)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "teleport"
    destination = "/etc"
  }

  provisioner "file" {
    content = templatefile("auth.teleport-conf.yaml.tftpl", {
      auth_server_ip  = scaleway_instance_server.teleport-auth-1.public_ip
      proxy_server_ip = scaleway_instance_server.teleport-proxy-1.public_ip
      tag_server_dns  = "${scaleway_domain_record.tag.name}.${scaleway_domain_record.tag.dns_zone}"
    })
    destination = "/etc/teleport.yaml"
  }

  provisioner "file" {
    content     = base64decode(data.scaleway_secret_version.license.data)
    destination = "/etc/teleport/license.pem"
  }

  provisioner "file" {
    content     = base64decode(data.scaleway_secret_version.ca-cert.data)
    destination = "/etc/access_graph_ca.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "while ! command -v tctl >/dev/null; do sleep 1; done",
      "while [ ! -s /var/lib/teleport/host_uuid ]; do sleep 1; done",
      "while ! tctl status >/dev/null; do sleep 1; done",
      "tctl create /etc/teleport/github-repo-role.yaml",
      "tctl create /etc/teleport/bot.yaml",
      "tctl create /etc/teleport/bot-token.yaml",
      # The purpose of the above is so GitHub Actions can apply the latter. Included here for convenience only.
      "tctl create /etc/teleport/azure-connector.yaml"
    ]
  }
}

output "auth-ip" {
  value = scaleway_instance_server.teleport-auth-1.public_ip
}
