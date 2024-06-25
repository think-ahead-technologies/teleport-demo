
resource "kubernetes_manifest" "secret-store" {
  manifest = yamldecode(templatefile("${path.module}/secret-store.yaml", {
    region     = var.SCW_REGION
    project_id = var.SCW_DEFAULT_PROJECT_ID
  }))
}

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


resource "kubernetes_secret" "scaleway-credentials-cert-manager" {
  metadata {
    name = "scaleway-credentials"
    # cert-manager is hardcoded to this namespace. It should be created automatically by Flux.
    namespace = "cert-manager"
  }
  type = "Opaque"
  data = {
    SCW_ACCESS_KEY = var.SCW_ACCESS_KEY
    SCW_SECRET_KEY = var.SCW_SECRET_KEY
    SCW_REGION     = var.SCW_REGION
    SCW_PROJECT_ID = var.SCW_DEFAULT_PROJECT_ID
  }
}

resource "scaleway_secret" "cluster-host-ca" {
  name        = "kubernetes"
  path        = "/teleport-demo/certificates/cluster-host-ca"
  description = "Host CA certificate retrieved from currently running Kubernetes cluster"
}

resource "null_resource" "retrieve-cluster-host-ca-to-secret" {
  provisioner "local-exec" {
    command = "./get-cluster-host-ca.sh teleport.thinkahead.dev ${scaleway_secret.cluster-host-ca.id} ${var.SCW_REGION}"
  }
}
