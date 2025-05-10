# Configure the Helm provider to interact with the Kubernetes cluster
provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
  }
}

locals {
  repo_url = "https://github.com/MCCE2024/INENPT-G8"
  repo_path = "gitops-base"
  app_name = "gitops-base"
  app_namespace = "argocd"
}

# Install ArgoCD via the official Helm chart
resource "helm_release" "argo_cd" {
  name             = "argocd"                                  # Name of the Helm release
  repository       = "https://argoproj.github.io/argo-helm"    # ArgoCD Helm chart repo
  chart            = "argo-cd"                                 # Chart name
  version          = "7.8.22"                                  # Specific version of the chart
  timeout          = 1200                                      # Max wait time (seconds)
  create_namespace = true                                      # Create the 'argocd' namespace if missing
  namespace        = "argocd"                                  # Target namespace for ArgoCD
  lint             = true                                      # Lint chart before applying
  wait             = true                                      # Wait until deployment is complete

  # Customize ArgoCD service to expose a LoadBalancer on ports 80 and 443
  values = [
      templatefile("app-values.yaml", {
        repo_url      = local.repo_url
        repo_path     = local.repo_path
        app_name      = local.app_name
        app_namespace = local.app_namespace
      })
  ]

  # Ensure kubeconfig exists before this release is deployed
  depends_on = [
    exoscale_sks_nodepool.sks_nodepool
  ]
}