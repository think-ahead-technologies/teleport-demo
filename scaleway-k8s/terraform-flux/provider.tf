terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    helm = {
      version = ">= 2.13"
    }
    scaleway = {
      source = "scaleway/scaleway"
    }
  }

  backend "s3" {
    bucket = "think-ahead-teleport-demo-terraform-state"
    key    = "scaleway-k8s/flux.tfstate"
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

provider "flux" {
  kubernetes = {
    host                   = local.kubeconfig.host
    token                  = local.kubeconfig.token
    cluster_ca_certificate = base64decode(local.kubeconfig.cluster_ca_certificate)
  }
  git = {
    url = "https://github.com/${var.GITHUB_ORG}/${var.GITHUB_REPO}"
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.GITHUB_ACCESS_TOKEN
    }
  }
}

provider "kubernetes" {
  host                   = local.kubeconfig.host
  token                  = local.kubeconfig.token
  cluster_ca_certificate = base64decode(local.kubeconfig.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.host
    token                  = local.kubeconfig.token
    cluster_ca_certificate = base64decode(local.kubeconfig.cluster_ca_certificate)
  }
}