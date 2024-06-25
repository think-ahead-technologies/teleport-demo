
locals {
  domain = "teleport.thinkahead.dev"
}

resource "scaleway_secret" "proxy-cert" {
  name        = "cert"
  path        = "/teleport-demo/certificates/proxy"
  description = "Teleport proxy certificate for ${var.DOMAIN}"
}

resource "scaleway_secret_version" "ca-cert-gen" {
  secret_id = scaleway_secret.proxy-cert.id
  data      = file("letsencrypt/live/${var.DOMAIN}/fullchain.pem")
}

resource "scaleway_secret" "proxy-key" {
  name        = "key"
  path        = "/teleport-demo/certificates/proxy"
  description = "Teleport proxy key for ${var.DOMAIN}"
}

resource "scaleway_secret_version" "proxy-key" {
  secret_id = scaleway_secret.proxy-key.id
  data      = file("letsencrypt/live/${var.DOMAIN}/privkey.pem")
}
