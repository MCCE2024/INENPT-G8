resource "exoscale_dbaas_pg" "pg" {
  name             = "inenpt-g8-db"         # Name des DBaaS-Services
  plan             = "starter-2"            # Tarif/Größe der Instanz
  maintenance_day  = "monday"               # Wochentag für Wartung
  maintenance_time = "10:00:00"             # Uhrzeit für Wartung
  termination_protection = false            # Schutz vor versehentlichem Löschen
  zone             = "at-vie-2"             # Exoscale-Zone

  pg_user_config {
    public_access = true                    # Erlaubt öffentlichen Zugriff (Achtung: Sicherheit beachten!)
  }
}

# Legt eine zusätzliche Datenbank im Service an
resource "exoscale_dbaas_pg_database" "appdb" {
  service_name = exoscale_dbaas_pg.pg.name
  name         = "appdb"                    # Name der App-Datenbank
}

# Legt einen Benutzer für die App-Datenbank an
resource "exoscale_dbaas_pg_user" "appuser" {
  service_name = exoscale_dbaas_pg.pg.name
  username     = "appuser"                  # Benutzername
  password     = var.pgdb_pw                # Passwort (als Variable, nicht hardcoded!)
  privileges {
    database   = exoscale_dbaas_pg_database.appdb.name
    permission = "ALL"                      # Alle Rechte auf die App-Datenbank
  }
}

# Outputs für die Weiterverwendung (z.B. in der App oder CI/CD)
output "db_host" {
  value = exoscale_dbaas_pg.pg.host    # Hostname des DB-Services
}

output "db_user" {
  value = exoscale_dbaas_pg.pg.user    # Default-Admin-User des DB-Services
}

output "db_password" {
  value     = exoscale_dbaas_pg.pg.password
  sensitive = true                          # Markiert als sensibel (wird nicht im Klartext angezeigt)
}

output "db_name" {
  value = exoscale_dbaas_pg.pg.database_name # Default-Datenbankname
}

output "appdb_name" {
  value = exoscale_dbaas_pg_database.appdb.name   # Name der App-Datenbank
}

output "appuser_username" {
  value = exoscale_dbaas_pg_user.appuser.username # App-Benutzername
}

output "appuser_password" {
  value     = exoscale_dbaas_pg_user.appuser.password
  sensitive = true                                # Markiert als sensibel
}