resource "exoscale_dbaas" "pg" {
  name = "postgres-db"
  type = "pg"
  plan = "hobbyist-2"
  zone = var.zone
 
  pg {
    version         = "15"
    backup_schedule = "04:00"
    ip_filter       = ["0.0.0.0/0"]
    pg_settings     = jsonencode({ timezone = "Europe/Berlin" })
  }
}
 
resource "exoscale_dbaas_pg_database" "appdb" {
  database_name = "appdb"
  service       = exoscale_dbaas.pg.name
  zone          = exoscale_dbaas.pg.zone
}
 
resource "exoscale_dbaas_pg_user" "appuser" {
  username = "appuser"
  service  = exoscale_dbaas.pg.name
  zone     = exoscale_dbaas.pg.zone
}
