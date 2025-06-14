provider "kubernetes" {
  config_path = local_sensitive_file.kubeconfig_file.filename
}

resource "kubernetes_secret" "pg_secret" {
  metadata {
    name      = "pg-secret"
    namespace = "default"  # <-- Required if not default
  }

  data = {
    admin_username = var.PGDB_ADMIN
    admin_password = var.PGDB_PW
  }

  type = "Opaque"
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }

  depends_on = [ exoscale_sks_cluster.sks_cluster ]
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }

  data = {
    apiKey = var.CLOUDFLARE_API_TOKEN
  }

  type = "Opaque"
  
}