resource "scaleway_instance_ip" "public_ip_1" {}

resource "scaleway_instance_user_data" "server" {
  server_id = scaleway_instance_server.teleport-server-1.id
  key       = "cloud-init"
  value = templatefile("vm.userdata.sh.tftpl", {
    TELEPORT_DOMAIN       = var.TELEPORT_DOMAIN
    TELEPORT_INVITE_TOKEN = file("node-invite.tok")
  })
}

resource "scaleway_instance_server" "teleport-server-1" {
  type  = "DEV1-M"
  image = "ubuntu_jammy"
  name  = "scw-teleport-demo-server"
  ip_id = scaleway_instance_ip.public_ip_1.id
}

output "server-ip" {
  value = scaleway_instance_ip.public_ip_1.address
}
