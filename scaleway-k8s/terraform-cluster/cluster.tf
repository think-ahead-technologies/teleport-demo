
resource "scaleway_k8s_cluster" "teleport" {
  name                        = "teleport"
  version                     = "1.29.1"
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.teleport.id
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "teleport" {
  depends_on = [scaleway_lb_ip.teleport] # to ensure the IP isn't destroyed too early
  cluster_id = scaleway_k8s_cluster.teleport.id
  name       = "teleport"
  node_type  = "DEV1-M"
  size       = 1
}

resource "scaleway_vpc_private_network" "teleport" {
  name = "teleport"
}

resource "scaleway_secret" "kubeconfig" {
  name        = "teleport-kubernetes-kubeconfig"
  path        = "/teleport-demo/kubernetes/kubeconfig"
  description = "Kubeconfig credentials for use by other Terraform stacks"
}

resource "scaleway_secret_version" "kubeconfig" {
  depends_on  = [scaleway_k8s_pool.teleport]
  description = "current"
  secret_id   = scaleway_secret.kubeconfig.id
  data = jsonencode({
    host                   = scaleway_k8s_cluster.teleport.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.teleport.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.teleport.kubeconfig[0].cluster_ca_certificate
  })
}
