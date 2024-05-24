
resource scaleway_lb_ip proxy {}

resource scaleway_lb main {
    ip_ids = [ scaleway_lb_ip.proxy.id ]
    name = "teleport-proxy-lb"
    type = "LB-S"
}


resource "scaleway_lb_frontend" "main" {
  lb_id        = scaleway_lb.main.id
  backend_id   = scaleway_lb_backend.proxy.id
  name         = "teleport-proxy"
  inbound_port = "443"
}

resource "scaleway_lb_backend" "proxy" {
  lb_id            = scaleway_lb.main.id
  name             = "teleport-proxy-backend"
  forward_protocol = "tcp"
  forward_port     = "3080"
  proxy_protocol   = "v2"
  server_ips = [ scaleway_instance_server.teleport-proxy-1.public_ip ]
}

resource "scaleway_domain_record" "proxy" {
  dns_zone = "thinkahead.dev"
  name     = "teleport"
  type     = "A"
  data     = scaleway_lb.main.ip_address
  ttl      = 60
}

output "lb-dns" {
  value = "${scaleway_domain_record.proxy.name}.${scaleway_domain_record.proxy.dns_zone}"
}
output "lb-ip" {
    value = scaleway_lb_ip.proxy.ip_address
}