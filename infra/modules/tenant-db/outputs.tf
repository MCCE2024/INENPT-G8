# Output: Name of the Kubernetes secret that stores database credentials.
output "kubernetes_secret_name" {
  description = "The name of the generated Kubernetes secret."
  value       = kubernetes_secret.db_secret.metadata[0].name
}

# Output: Username created for the database user.
output "database_user" {
  description = "The user created for the database."
  value       = exoscale_dbaas_pg_user.db_user.username
}

# Output: Name of the PostgreSQL database created by this module.
output "database_name" {
  description = "The name of the database created."
  value       = exoscale_dbaas_pg_database.db.database_name
}
