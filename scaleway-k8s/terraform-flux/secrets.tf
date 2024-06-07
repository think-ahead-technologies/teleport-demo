
resource "helm_release" "external-secrets" {
  name      = "external-secrets"
  namespace = "kube-system"

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set {
    name  = "installCRDs"
    value = "true"
  }
}