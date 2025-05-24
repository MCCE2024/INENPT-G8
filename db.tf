resource "exoscale_dbaas_pg" "pg" {
  name             = "inenpt-g8-db"         # Name des DBaaS-Services
  plan             = "starter-2"            # Tarif/Größe der Instanz
  maintenance_day  = "monday"
  maintenance_time = "10:00:00"
  termination_protection = false
  zone             = "at-vie-2"

  pg_user_config {
    public_access = true
  }
}

resource "exoscale_dbaas_pg_database" "appdb" {
  service = exoscale_dbaas_pg.pg.id
  name    = "appdb"
}

resource "exoscale_dbaas_pg_user" "appuser" {
  service    = exoscale_dbaas_pg.pg.id
  name       = "appuser"
  password   = var.pgdb_pw
  privileges = ["appdb:ALL"]
  zone       = "at-vie-2"
}