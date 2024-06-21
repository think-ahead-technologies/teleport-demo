terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }

  backend "s3" {
    bucket = "think-ahead-teleport-demo-terraform-state"
    key    = "scaleway-k8s/secrets.tfstate"
    region = "fr-par"
    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }

  required_version = ">= 1.7.0"
}

provider "scaleway" {
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY
  project_id = var.SCW_DEFAULT_PROJECT_ID
  zone       = "fr-par-2"
  region     = "fr-par"
}

provider "kubernetes" {
  host                   = local.kubeconfig.host
  token                  = local.kubeconfig.token
  cluster_ca_certificate = base64decode(local.kubeconfig.cluster_ca_certificate)
}


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
