resource "exoscale_dbaas" "pg" {
  # Defines a PostgreSQL database service on Exoscale
  name                   = "postgres-db"
  type                   = "pg"
  plan                   = "hobbyist-2"
  zone                   = var.zone
  termination_protection = false # Enable termination protection to prevent accidental deletion

  pg {
    # PostgreSQL-specific configuration
    version         = "15"                                       # PostgreSQL version to use
    backup_schedule = "04:00"                                    # Daily backup time (UTC)
    ip_filter       = ["0.0.0.0/0"]                              # Allow connections from any IP address (not recommended for production)
    pg_settings     = jsonencode({ timezone = "Europe/Berlin" }) # Set timezone setting for PostgreSQL
  }
}

resource "exoscale_dbaas_pg_database" "appdb" {
  # Creates a PostgreSQL database named "appdb" in the above service
  database_name = "appdb"
  service       = exoscale_dbaas.pg.name
  zone          = exoscale_dbaas.pg.zone
}

resource "exoscale_dbaas_pg_user" "appuser" {
  # Creates a PostgreSQL user named "appuser" with access to the service
  username = "appuser"
  service  = exoscale_dbaas.pg.name
  zone     = exoscale_dbaas.pg.zone
}
