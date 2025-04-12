# https://labs.on-clouds.at/codelabs/iac-opentofu-gitops/?index=..%2F..index#0
provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
  }
}

resource "helm_release" "argo_cd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.22"
  timeout          = 1200
  create_namespace = true
  namespace        = "argocd"
  lint             = true
  wait             = true

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

  depends_on = [
    local_sensitive_file.kubeconfig_file
  ]
}