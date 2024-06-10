
# Deploy external-secrets chart, so its CRDs are available in
#  time for `terraform plan` in the terraform-secrets stack.

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

