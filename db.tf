resource "exoscale_dbaas" "pg" {
  name             = "inenpt-g8-db"         # Name des DBaaS-Services
  plan             = "starter-2"            # Tarif/Größe der Instanz
  type             = "pg"
  zone             = "at-vie-2"             # Exoscale-Zone
}

# Legt eine zusätzliche Datenbank im Service an
resource "exoscale_dbaas_pg_database" "appdb" {
  service = exoscale_dbaas.pg.id
  database_name         = "appdb"                    # Name der App-Datenbank
  zone         = "at-vie-2" 
}

# Legt einen Benutzer für die App-Datenbank an
resource "exoscale_dbaas_pg_user" "appuser" {
  service = exoscale_dbaas.pg.id
  username     = "appuser"                  # Benutzername
  zone         = "at-vie-2"                 # Exoscale-Zone
}