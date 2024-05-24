
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
  name  = "scw-teleport-onprem-auth-1"
  tags = var.TAGS
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
    content = templatefile("auth.teleport-conf.yaml.tftpl", {
      proxy_server_ip = scaleway_instance_server.teleport-proxy-1.public_ip
    })
    destination = "/etc/teleport.yaml"
  }

  provisioner "file" {
    content     = file("license.pem")
    destination = "/etc/teleport-license.pem"
  }
}

output "auth-ip" {
  value = scaleway_instance_server.teleport-auth-1.public_ip
}
