resource "exoscale_dbaas" "my_pg" {
  name = "my-postgres-db"
  type = "pg"
  plan = "startup-4"
  zone = "de-fra-1"
 
  pg {
    version         = "15"
    backup_schedule = "04:00"
    ip_filter       = ["0.0.0.0/0"]
    pg_settings     = jsonencode({ timezone = "Europe/Berlin" })
  }
}