
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "cert-cluster-issuer" {
  manifest = provider::kubernetes::manifest_decode(file("cert-cluster-issuer.yaml"))
}

resource "kubernetes_secret" "scaleway-credentials" {
  metadata {
    name      = "scaleway-credentials"
    namespace = "cert-manager"
  }
  type = "Opaque"
  data = {
    SCW_ACCESS_KEY = var.SCW_ACCESS_KEY
    SCW_SECRET_KEY = var.SCW_SECRET_KEY
  }
}

resource "helm_release" "scaleway-certmanager-webhook" {
  name       = "scaleway-certmanager-webhook"
  namespace  = "cert-manager"
  repository = "https://helm.scw.cloud/"
  chart      = "scaleway-certmanager-webhook"
}