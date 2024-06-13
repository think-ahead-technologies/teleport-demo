
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
  type  = "DEV1-M"
  image = "ubuntu_jammy"
  name  = "scw-teleport-demo-auth"
  tags  = var.TAGS
  ip_id = scaleway_instance_ip.temp_auth_ip_1.id
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
      tag_server_ip   = scaleway_instance_ip.temp_tag_ip_1.address
      proxy_server_ip = scaleway_instance_server.teleport-proxy-1.public_ip
    })
    destination = "/etc/teleport.yaml"
  }

  provisioner "file" {
    content     = file("license.pem")
    destination = "/etc/teleport/license.pem"
  }

  provisioner "file" {
    content     = file("keys/ca.crt")
    destination = "/etc/access_graph_ca.pem"
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
