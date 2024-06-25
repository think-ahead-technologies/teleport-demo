resource "scaleway_lb_ip" "teleport" {}

resource "scaleway_domain_record" "teleport" {
  dns_zone = "thinkahead.dev"
  name     = "teleport"
  type     = "A"
  data     = scaleway_lb_ip.teleport.ip_address
  ttl      = 60
}

resource "scaleway_secret" "kubernetes-cluster-ip" {
  name = "lb-ip"
  path = "/teleport-demo/kubernetes"
}

resource "scaleway_secret_version" "kubernetes-cluster-ip" {
  secret_id = scaleway_secret.kubernetes-cluster-ip.id
  data      = scaleway_lb_ip.teleport.ip_address
}

output "fixed-lb-ip" {
  value = scaleway_lb_ip.teleport.ip_address
}

output "pool-node-ip" {
  value = scaleway_k8s_pool.teleport.nodes[0].public_ip
}