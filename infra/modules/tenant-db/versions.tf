terraform {
  # Declare required providers and versions
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale" # Exoscale cloud provider
      version = "0.64.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" # Kubernetes provider
      version = "2.37.1"               # Specific version
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}