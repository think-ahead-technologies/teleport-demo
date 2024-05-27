resource "scaleway_instance_ip" "public_ip_1" {}

resource "scaleway_instance_user_data" "proxy" {
  server_id = scaleway_instance_server.teleport-proxy-1.id
  key       = "cloud-init"
  value = templatefile("vm.userdata.sh.tftpl", {
    TELEPORT_EDITION = var.TELEPORT_EDITION
    TELEPORT_VERSION = var.TELEPORT_VERSION
  })
}

resource "scaleway_instance_server" "teleport-proxy-1" {
  type  = "DEV1-M"
  image = "ubuntu_jammy"
  name  = "scw-teleport-onprem-proxy-1"
  tags  = var.TAGS
  ip_id = scaleway_instance_ip.public_ip_1.id
}

resource "null_resource" "copy-teleport-conf-proxy" {

  connection {
    host        = scaleway_instance_server.teleport-proxy-1.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.SSH_KEYFILE)
    timeout     = "2m"
  }

  provisioner "file" {
    content = templatefile("proxy.teleport-conf.yaml.tftpl", {
      auth_server_ip = scaleway_instance_server.teleport-auth-1.public_ip
    })
    destination = "/etc/teleport.yaml"
  }

  provisioner "file" {
    content     = file("fullchain.pem")
    destination = "/etc/letsencrypt-cert.pem"
  }

  provisioner "file" {
    content     = file("privkey.pem")
    destination = "/etc/letsencrypt-key.pem"
  }

  provisioner "file" {
    content     = file("tld-fullchain.pem")
    destination = "/etc/letsencrypt-cert-tld.pem"
  }

  provisioner "file" {
    content     = file("tld-privkey.pem")
    destination = "/etc/letsencrypt-key-tld.pem"
  }
}

output "proxy-ip" {
  value = scaleway_instance_server.teleport-proxy-1.public_ip
}
