resource "exoscale_dbaas_service" "pg" {
  name             = "inenpt-g8-db"
  type             = "pg"
  plan             = "starter-2"
  maintenance_day  = "monday"
  maintenance_time = "10:00:00"
  termination_protection = false
  zone             = "at-vie-2"

  pg_user_config {
    public_access = true
  }
}

resource "exoscale_dbaas_pg_database" "appdb" {
  service_name = exoscale_dbaas_service.pg.name
  name         = "appdb"
}

#resource "exoscale_dbaas_pg_user" "appuser" {
 #service_name = exoscale_dbaas_service.pg.name
  #username     = "appuser"
  #password     = "securepassword123!" # Am besten als Variable oder Secret verwalten!
  # Optional: privileges für bestimmte Datenbanken
  # privileges {
  #   database = exoscale_dbaas_pg_database.appdb.name
  #   permission = "ALL"
  # }
#}

output "db_host" {
  value = exoscale_dbaas_service.pg.host
}

output "db_user" {
  value = exoscale_dbaas_service.pg.user
}

output "db_password" {
  value     = exoscale_dbaas_service.pg.password
  sensitive = true
}

output "db_name" {
  value = exoscale_dbaas_service.pg.database_name
}

output "appdb_name" {
  value = exoscale_dbaas_pg_database.appdb.name
}

output "appuser_username" {
  value = exoscale_dbaas_pg_user.appuser.username
}

output "appuser_password" {
  value     = exoscale_dbaas_pg_user.appuser.password
  sensitive = true
}