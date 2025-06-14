# Define where to store the state file (S3 remote backend)
terraform {
  backend "s3" {
    bucket = "inenpt-state"      # S3 bucket to store the .tfstate file
    key    = "terraform.tfstate" # Path to state file within bucket
    region = "us-east-1"         # AWS region for S3
  }

  # Declare required providers and versions
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale" # Exoscale cloud provider
      version = "0.64.1"
    }
    helm = {
      source  = "hashicorp/helm" # Helm chart provider
      version = "2.12.1"         # Specific version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" # Kubernetes provider
      version = "2.37.1"               # Specific version
    }
  }
}

# Instantiate the Exoscale provider (credentials from env/vars/secrets)
provider "exoscale" {}
