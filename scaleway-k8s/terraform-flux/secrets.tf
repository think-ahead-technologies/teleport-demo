
resource "kubernetes_secret" "scaleway-credentials" {
  metadata {
    name      = "scaleway-credentials"
    namespace = "kube-system"
  }
  type = "Opaque"
  data = {
    SCW_ACCESS_KEY = var.SCW_ACCESS_KEY
    SCW_SECRET_KEY = var.SCW_SECRET_KEY
    SCW_REGION     = var.SCW_REGION
    SCW_PROJECT_ID = var.SCW_DEFAULT_PROJECT_ID
  }
}

resource "scaleway_secret" "teleport-license" {
  name        = "teleport-license"
  path        = "/teleport-demo/license"
  description = "Teleport Enterprise license file"
}

resource "scaleway_secret_version" "teleport-license" {
  description = "current"
  secret_id   = scaleway_secret.teleport-license.id
  data        = file("${path.module}/license.pem")
}

resource "helm_release" "external-secrets" {
  name = "external-secrets"
  #   namespace = kubernetes_namespace.external-secrets.id
  namespace = "kube-system"

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# resource "kubernetes_namespace" "external-secrets" {
#   metadata {
#     name = "external-secrets"
#     labels = {
#       "pod-security.kubernetes.io/enforce" = "baseline"
#     }
#   }
# }

# REFERENCE ONLY. The real secret should be generated by Flux
# resource "kubernetes_secret" "license-deleteme" {
#   metadata {
#     name      = "license"
#     namespace = "teleport"
#   }
#   data = {
#     "license.pem" = file("${path.module}/license.pem")
#   }
#   type = "generic"
# }