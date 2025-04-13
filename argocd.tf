# Configure the Helm provider to interact with the Kubernetes cluster
provider "helm" {
  kubernetes {
    config_path = local_sensitive_file.kubeconfig_file.filename
  }
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
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
          ports = {
            http  = 80
            https = 443
          }
        }
      }
    })
  ]

  # Ensure kubeconfig exists before this release is deployed
  depends_on = [
    local_sensitive_file.kubeconfig_file
  ]
}