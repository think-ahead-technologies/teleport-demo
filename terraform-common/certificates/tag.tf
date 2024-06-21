
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
