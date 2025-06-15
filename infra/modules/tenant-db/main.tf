# Creates the PostgreSQL user with the specified username and the generated password.
resource "exoscale_dbaas_pg_user" "db_user" {
  username = var.database_user
  service  = var.dbaas_service_name
  zone     = var.dbaas_service_zone
}

# Creates the PostgreSQL database itself.
# It depends on the user being created first.
resource "exoscale_dbaas_pg_database" "db" {
  database_name = var.database_name
  service       = var.dbaas_service_name
  zone          = var.dbaas_service_zone
  depends_on = [
    exoscale_dbaas_pg_user.db_user
  ]
}

# Fetches the connection URI for the newly created database and user.
# This is a convenient way to get the full connection string without building it manually.
data "exoscale_database_uri" "db_uri" {
  name = var.dbaas_service_name
  type = "pg"
  zone = var.dbaas_service_zone
  
  # Ensure this data source runs after the database is created.
  depends_on = [
    exoscale_dbaas_pg_database.db
  ]
}

# Creates a Kubernetes namespace
resource "kubernetes_namespace" "tenant_namespace" {
  metadata {
    name = var.database_name
  }
}

# Creates the Kubernetes secret with the database credentials.
resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = var.database_name
    namespace = var.kubernetes_namespace
  }

  # The data map contains the sensitive information.
  # It's automatically base64 encoded by Terraform.
  data = {
    "DB_HOST"     = data.exoscale_database_uri.db_uri.host
    "DB_PORT"     = data.exoscale_database_uri.db_uri.port
    "DB_NAME"     = var.database_name
    "DB_USER"     = var.database_user
    "DB_PASSWORD" = exoscale_dbaas_pg_user.db_user.password # The password is fetched from the user resource
    "DB_URI"      = data.exoscale_database_uri.db_uri.uri # Full connection string
  }

  type = "Opaque"

  # Ensures the secret is only created after the database and user exist.
  depends_on = [
    exoscale_dbaas_pg_database.db,
    exoscale_dbaas_pg_user.db_user,
    data.exoscale_database_uri.db_uri,
  ]
}
