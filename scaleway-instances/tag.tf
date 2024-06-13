
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

resource "scaleway_instance_server" "teleport-tag-1" {
  # Some setup code depends on the
  depends_on = [null_resource.copy-teleport-conf-auth]
  type       = "DEV1-M"
  image      = "ubuntu_jammy"
  name       = "scw-teleport-demo-tag"
  tags       = var.TAGS
  ip_id      = scaleway_instance_ip.temp_tag_ip_1.id
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
    content     = file("keys/tag.crt")
    destination = "/etc/access-graph-tls.crt"
  }

  provisioner "file" {
    content     = file("keys/tag.key")
    destination = "/etc/access-graph-tls.key"
  }

  provisioner "file" {
    content = templatefile("tag.teleport-conf.yaml.tftpl", {
      db_access_string = local.db_access_string
    })
    destination = "/etc/tag-config.yaml"
  }
}

output "tag-ip" {
  value = scaleway_instance_server.teleport-tag-1.public_ip
}
