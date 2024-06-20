# To generate a Scaleway certificate:
# - Install certbot on development machine
# - Run:
#     certbot certonly --manual --preferred-challenges dns -d "teleport.thinkahead.dev" --config-dir letsencrypt --work-dir letsencrypt --logs-dir letsencrypt --email teleport-on-prem@think-ahead.tech
# - Then deploy this resource with the challenge provided by that command's output.
# resource "scaleway_domain_record" "letsencrypt-challenge" {
#   dns_zone = "thinkahead.dev"
#   name     = "_acme-challenge.teleport"
#   type     = "TXT"
#   data     = "mSEahpICF7XHmjzcMHhfGhkmsXuwWees2zo_SloVq7w"
#   ttl      = 60
# }

resource "scaleway_secret" "ca-cert-gen" {
  name        = "cert"
  path        = "/teleport-demo/instances/ca"
  description = "Certificate Authority cert"
}

resource "scaleway_secret_version" "ca-cert-gen" {
  secret_id = scaleway_secret.ca-cert-gen.id
  data      = file("ca.crt")
  lifecycle {
    ignore_changes = [data]
  }
}

resource "scaleway_secret" "ca-key-gen" {
  name        = "key"
  path        = "/teleport-demo/instances/ca"
  description = "Certificate Authority cert"
}

resource "scaleway_secret_version" "ca-key-gen" {
  secret_id = scaleway_secret.ca-key-gen.id
  data      = file("ca.key")
  lifecycle {
    ignore_changes = [data]
  }
}


resource "scaleway_secret" "tag-cert" {
  name        = "cert"
  path        = "/teleport-demo/instances/tag"
  description = "Teleport Access Graph certificate, with SANs for instance-based and Kubernetes-based deployments"
}

resource "scaleway_secret_version" "tag-cert" {
  secret_id = scaleway_secret.tag-cert.id
  data      = file("tag.crt")
  lifecycle {
    ignore_changes = [data]
  }
}

resource "scaleway_secret" "tag-key" {
  name        = "key"
  path        = "/teleport-demo/instances/tag"
  description = "Teleport Access Graph private key"
}

resource "scaleway_secret_version" "tag-key" {
  secret_id = scaleway_secret.tag-key.id
  data      = file("tag.key")
  lifecycle {
    ignore_changes = [data]
  }
}
