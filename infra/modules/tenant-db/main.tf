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
    "DB_URI"      = "postgresql://${exoscale_dbaas_pg_user.db_user.username}:${exoscale_dbaas_pg_user.db_user.password}@${data.exoscale_database_uri.db_uri.host}:${data.exoscale_database_uri.db_uri.port}/${var.database_name}"
  }

  type = "Opaque"

  # Ensures the secret is only created after the database and user exist.
  depends_on = [
    exoscale_dbaas_pg_database.db,
    exoscale_dbaas_pg_user.db_user,
    data.exoscale_database_uri.db_uri,
  ]
}

provider "postgresql" {
  host            = data.exoscale_database_uri.db_uri.host
  port            = data.exoscale_database_uri.db_uri.port
  database        = exoscale_dbaas_pg_database.db.database_name
  username        = var.PGDB_ADMIN
  password        = var.PGDB_PW
  sslmode         = "require" # Exoscale DBaaS typically requires SSL
  connect_timeout = 400
}

# The null_resource is now only responsible for inserting data.
# It depends on the postgresql_table resource to ensure the table
# exists before the INSERT statements are run.
resource "null_resource" "product_table_setup" {

  # Create a dependency on the table resource.
  depends_on = [data.exoscale_database_uri.db_uri]

  # The provisioner will run the psql command to execute our SQL.
  # Make sure 'psql' is in your system's PATH.
  provisioner "local-exec" {
    command = <<-EOT
      psql "host=${data.exoscale_database_uri.db_uri.host} port=${data.exoscale_database_uri.db_uri.port} user=${var.PGDB_ADMIN} password=${var.PGDB_PW} dbname=${exoscale_dbaas_pg_database.db.database_name}" -c "
        -- Create the table within the 'products' schema if it doesn't already exist.
        CREATE TABLE IF NOT EXISTS public.product (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          price NUMERIC(10, 2) NOT NULL
        );

        -- Insert 3 random products into the 'product' table.
        INSERT INTO public.product (name, price) VALUES ('Product A', 100.00), ('Product B', 80.00), ('Product C', 20.00);
      "
    EOT
  }
}

# Grant USAGE on the 'public' schema. Without this, the user cannot "see"
# any tables within the schema, even if they have table-level permissions.
resource "postgresql_grant" "schema_usage" {
  database    = var.database_name
  role        = var.database_user
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [null_resource.product_table_setup]
}

# Grant read/write permissions on the 'product' table.
# SELECT: read data
# INSERT: add new rows
# UPDATE: modify existing rows
# DELETE: remove rows
resource "postgresql_grant" "table_permissions" {
  database    = var.database_name
  role        = var.database_user
  schema      = "public"
  object_type = "table"
  objects     = ["product"]
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  depends_on = [null_resource.product_table_setup]
}

# Grant permissions on the sequence for the 'id' column.
# The 'SERIAL' type creates a sequence behind the scenes (product_id_seq).
# The user needs USAGE and SELECT permissions on it to allow the id to auto-increment
# when a new row is INSERTed.
resource "postgresql_grant" "sequence_permissions" {
  database    = var.database_name
  role        = var.database_user
  schema      = "public"
  object_type = "sequence"
  objects     = ["product_id_seq"]
  privileges  = ["USAGE", "SELECT"]

  depends_on = [null_resource.product_table_setup]
}
