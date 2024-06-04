
# resource "scaleway_lb_ip" "teleport" {
#   /* TODO resource may be unnecessary */
#   zone       = "fr-par-1"
#   project_id = scaleway_k8s_cluster.teleport.project_id
# }

resource "kubernetes_namespace" "teleport" {
  metadata {
    name = "teleport"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

resource "kubernetes_secret" "license" {
  metadata {
    name      = "license"
    namespace = kubernetes_namespace.teleport.id
  }
  data = {
    "license.pem" = file("${path.module}/license.pem")
  }
  type = "generic"
}

resource "helm_release" "teleport-cluster" {
  name      = "teleport-cluster"
  namespace = kubernetes_namespace.teleport.id

  depends_on = [kubernetes_namespace.teleport]

  repository = "https://charts.releases.teleport.dev"
  chart      = "teleport-cluster"

  # NB See the following for an exhaustive list of settings:
  #  https://github.dev/gravitational/teleport/blob/4160786a3e6fabd9b0dcd54354820b222a22535b/examples/chart/teleport-cluster/values.yaml
  values = ["${file("helm-values.yaml")}"]
  #   set {
  #     name  = "clusterName"
  #     value = "${scaleway_domain_record.k8s.name}.${scaleway_domain_record.k8s.dns_zone}"
  #   }

  #   set {
  #     name  = "proxyProtocol"
  #     value = "on"
  #   }

  #   set {
  #     name  = "proxyListenerMode"
  #     value = "multiplex"
  #   }

  #   set {
  #     name  = "enterprise"
  #     value = "true"
  #   }

  #   set {
  #     name  = "highAvailability.certManager.enabled"
  #     value = "true"
  #   }

  #   set {
  #     name  = "highAvailability.certManager.issuerName"
  #     value = "letsencrypt-prod"
  #   }

  #   set {
  #     name  = "highAvailability.certManager.issuerKind"
  #     value = "ClusterIssuer"
  #   }

  #   set {
  #     name  = "ingress.enabled"
  #     value = "true"
  #   }

  #   set {
  #     name  = "ingress.spec.ingressClassName"
  #     value = "nginx"
  #   }

  #   set {
  #     name  = "service.type"
  #     value = "ClusterIP"
  #   }

  #   set {
  #     name  = "annotations.ingress"
  #     value = "nginx.ingress.kubernetes.io/backend-protocol: HTTPS"
  #   }
}

# resource "scaleway_domain_record" "k8s" {
#   dns_zone = "thinkahead.dev"
#   name     = "teleport"
#   type     = "A"
#   data     = scaleway_lb_ip.teleport.ip_address
#   ttl      = 60
# }
