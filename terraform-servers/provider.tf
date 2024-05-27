terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }

  backend "s3" {
    bucket                      = "think-ahead-teleport-demo-terraform-state"
    key                         = "prod.tfstate"
    region                      = "fr-par"
    endpoint                    = "https://s3.fr-par.scw.cloud"
    skip_credentials_validation = true
    skip_region_validation      = true
  }

  required_version = ">= 1.5.0"
}

provider "scaleway" {
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY
  project_id = var.SCW_DEFAULT_PROJECT_ID
  zone       = "fr-par-2"
  region     = "fr-par"
}

