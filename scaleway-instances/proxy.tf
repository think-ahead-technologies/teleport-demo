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
  name  = "scw-teleport-demo-proxy"
  tags  = var.TAGS
  ip_id = scaleway_instance_ip.public_ip_1.id
}

data "scaleway_secret" "proxy-key" {
  name = "key"
  path = "/teleport-demo/instances/domain"
}

data "scaleway_secret_version" "proxy-key" {
  secret_id = data.scaleway_secret.proxy-key.id
  revision  = "latest"
}

data "scaleway_secret" "proxy-certificate" {
  name = "cert"
  path = "/teleport-demo/instances/domain"
}

data "scaleway_secret_version" "proxy-certificate" {
  secret_id = data.scaleway_secret.proxy-certificate.id
  revision  = "latest"
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
    content     = base64decode(data.scaleway_secret_version.proxy-certificate.data)
    destination = "/etc/teleport-letsencrypt-cert.pem"
  }

  provisioner "file" {
    content     = base64decode(data.scaleway_secret_version.proxy-key.data)
    destination = "/etc/teleport-letsencrypt-key.pem"
  }
}

output "proxy-ip" {
  value = scaleway_instance_server.teleport-proxy-1.public_ip
}
