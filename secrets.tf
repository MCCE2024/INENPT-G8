provider "kubernetes" {
  config_path = local_sensitive_file.kubeconfig_file.filename
}

resource "kubernetes_secret" "pg_secret" {
  metadata {
    name      = "pg-secret"
    namespace = "default"  # <-- Required if not default
  }

  data = {
    admin_username = base64encode(var.PGDB_ADMIN)
    admin_password = base64encode(var.PGDB_PW)
  }

  type = "Opaque"
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }

  data = {
    apiKey = base64encode(var.CLOUDFLARE_API_TOKEN)
  }

  type = "Opaque"
  
}