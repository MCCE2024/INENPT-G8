# Name of the existing Exoscale DBaaS PostgreSQL service to attach the database to.
variable "dbaas_service_name" {
  type        = string
  description = "The name of the parent Exoscale DBaaS PostgreSQL service."
}

# Zone in which the DBaaS PostgreSQL service is deployed.
variable "dbaas_service_zone" {
  type        = string
  description = "The zone where the Exoscale DBaaS service is running."
}

# Name for the new database to be created in the DBaaS instance.
variable "database_name" {
  type        = string
  description = "The name for the new PostgreSQL database."
  default     = "appdb"
}

# Username for the new database user.
variable "database_user" {
  type        = string
  description = "The username for the new PostgreSQL user."
  default     = "appuser"
}

# Kubernetes namespace where the database credentials secret will be stored.
variable "kubernetes_namespace" {
  type        = string
  description = "The Kubernetes namespace where the secret will be created."
  default     = "default"
}

# Admin username for the PostgreSQL instance. Marked as sensitive.
# DB
variable "PGDB_ADMIN" {
  description = "The admin username for the PostgreSQL database."
  type        = string
  default     = "admin"
  sensitive = true
  
}

# Admin password for the PostgreSQL instance. Marked as sensitive.
variable "PGDB_PW" {
  description = "The admin password for the PostgreSQL database."
  type        = string
  default     = "admin_password"
  sensitive = true
}