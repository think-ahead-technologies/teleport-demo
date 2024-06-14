
resource "scaleway_instance_ip" "temp_tag_ip_1" {}

resource "scaleway_instance_user_data" "tag" {
  server_id = scaleway_instance_server.teleport-tag-1.id
  key       = "cloud-init"
  value = templatefile("tag.userdata.sh.tftpl", {
    proxy_server_ip        = scaleway_instance_server.teleport-proxy-1.public_ip
    access_graph_image_tag = var.ACCESS_GRAPH_VERSION
    teleport_dns           = "${scaleway_domain_record.proxy.name}.${scaleway_domain_record.proxy.dns_zone}"
  })
}

resource "scaleway_domain_record" "tag" {
  dns_zone = "thinkahead.dev"
  name     = "teleport-access-graph"
  type     = "A"
  data     = scaleway_instance_ip.temp_tag_ip_1.address
  ttl      = 60
}

resource "scaleway_instance_server" "teleport-tag-1" {
  depends_on = [null_resource.copy-teleport-conf-auth, azurerm_postgresql_flexible_server_database.teleport]
  type       = "DEV1-M"
  image      = "ubuntu_jammy"
  name       = "scw-teleport-demo-tag"
  tags       = var.TAGS
  ip_id      = scaleway_instance_ip.temp_tag_ip_1.id
}

data "scaleway_secret" "tag-cert" {
  name = "cert"
  path = "/teleport-demo/instances/tag"
}

data "scaleway_secret_version" "tag-cert" {
  secret_id = data.scaleway_secret.tag-cert.id
  revision  = "latest"
}

data "scaleway_secret" "tag-key" {
  name = "key"
  path = "/teleport-demo/instances/tag"
}

data "scaleway_secret_version" "tag-key" {
  secret_id = data.scaleway_secret.tag-key.id
  revision  = "latest"
}

resource "null_resource" "copy-teleport-conf-tag" {
  connection {
    host        = scaleway_instance_server.teleport-tag-1.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.SSH_KEYFILE)
    timeout     = "2m"
  }

  provisioner "file" {
    content     = base64decode(data.scaleway_secret_version.tag-cert.data)
    destination = "/etc/access-graph-tls.crt"
  }

  provisioner "file" {
    content     = base64decode(data.scaleway_secret_version.tag-key.data)
    destination = "/etc/access-graph-tls.key"
  }

  provisioner "file" {
    content = templatefile("tag.teleport-conf.yaml.tftpl", {
      db_access_string = local.db_access_string
    })
    destination = "/etc/tag-config.yaml"
  }
}

resource "null_resource" "wait-for-tag" {
  depends_on = [null_resource.copy-teleport-conf-tag]
  provisioner "local-exec" {
    command = "while ! nc ${scaleway_domain_record.tag.name}.${scaleway_domain_record.tag.dns_zone} 50051 < /dev/null; do sleep 1; done"
  }
}

resource "null_resource" "restart-auth-server" {
  depends_on = [null_resource.wait-for-tag]
  connection {
    host        = scaleway_instance_server.teleport-auth-1.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.SSH_KEYFILE)
  }
  provisioner "remote-exec" {
    inline = ["systemctl restart teleport"]
  }
}

resource "null_resource" "restart-proxy-server" {
  depends_on = [null_resource.restart-auth-server]
  connection {
    host        = scaleway_instance_server.teleport-proxy-1.public_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.SSH_KEYFILE)
  }
  provisioner "remote-exec" {
    inline = ["systemctl restart teleport"]
  }
}

resource "null_resource" "wait-for-teleport" {
  depends_on = [null_resource.restart-proxy-server]
  provisioner "local-exec" {
    command = "while ! curl -Is https://${scaleway_domain_record.proxy.name}.${scaleway_domain_record.proxy.dns_zone} >/dev/null; do sleep 1; done"
  }
}

output "tag-ip" {
  value = scaleway_instance_server.teleport-tag-1.public_ip
}

output "tag-dns" {
  value = "${scaleway_domain_record.tag.name}.${scaleway_domain_record.tag.dns_zone}"
}
