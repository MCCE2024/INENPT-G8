terraform {
  backend "s3" {
    bucket = "inenpt-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

provider "exoscale" {}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
  }
}