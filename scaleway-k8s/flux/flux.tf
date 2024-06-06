
resource "github_repository" "this" {
  name        = var.GITHUB_REPO
  description = var.GITHUB_REPO
  visibility  = "private"
  auto_init   = true
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]
  embedded_manifests = true
  path               = "clusters/teleport"
}
