
# Retrieve cluster credentials and store them in local.kubeconfig

data "scaleway_secret" "kubeconfig" {
  name = "teleport-kubernetes-kubeconfig"
  path = "/teleport-demo/kubernetes/kubeconfig"
}

data "scaleway_secret_version" "kubeconfig" {
  secret_id = data.scaleway_secret.kubeconfig.secret_id
  revision  = "latest"
}

locals {
  kubeconfig = jsondecode(base64decode(data.scaleway_secret_version.kubeconfig.data))
}
