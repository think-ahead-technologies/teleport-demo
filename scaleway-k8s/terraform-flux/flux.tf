
resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "scaleway-k8s/flux-config/clusters/teleport"
}
