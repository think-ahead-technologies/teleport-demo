
resource "scaleway_k8s_cluster" "teleport" {
  name                        = "teleport"
  version                     = "1.29.1"
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.teleport.id
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "teleport" {
  cluster_id = scaleway_k8s_cluster.teleport.id
  name       = "teleport"
  node_type  = "DEV1-M"
  size       = 1
}

resource "scaleway_vpc_private_network" "teleport" {
  name = "teleport"
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.teleport] # at least one pool here
  triggers = {
    host                   = scaleway_k8s_cluster.teleport.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.teleport.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.teleport.kubeconfig[0].cluster_ca_certificate
  }
}