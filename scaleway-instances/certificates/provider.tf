terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }

  backend "s3" {
    bucket = "think-ahead-teleport-demo-terraform-state"
    key    = "scaleway-instances-certificates.tfstate"
    region = "fr-par"
    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }

  required_version = ">= 1.6.1"
}

provider "scaleway" {
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY
  project_id = var.SCW_DEFAULT_PROJECT_ID
  zone       = "fr-par-2"
  region     = "fr-par"
}
