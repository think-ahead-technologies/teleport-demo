
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

# TODO move the whole of cert-manager into kube-system
resource "kubernetes_secret" "scaleway-credentials-cert-manager" {
  depends_on = [kubernetes_namespace.cert-manager]
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

resource "kubernetes_secret" "scaleway-credentials" {
  depends_on = [kubernetes_namespace.cert-manager]
  metadata {
    name      = "scaleway-credentials"
    namespace = "kube-system"
  }
  type = "Opaque"
  data = {
    SCW_ACCESS_KEY = var.SCW_ACCESS_KEY
    SCW_SECRET_KEY = var.SCW_SECRET_KEY
  }
}

resource "kubernetes_namespace" "teleport" {
  metadata {
    name = "teleport"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

resource "kubernetes_secret" "license" {
  metadata {
    name      = "license"
    namespace = "teleport"
  }
  data = {
    "license.pem" = file("${path.module}/license.pem")
  }
  type = "generic"
}