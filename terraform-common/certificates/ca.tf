
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
