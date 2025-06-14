variable "dbaas_service_name" {
  type        = string
  description = "The name of the parent Exoscale DBaaS PostgreSQL service."
}

variable "dbaas_service_zone" {
  type        = string
  description = "The zone where the Exoscale DBaaS service is running."
}

variable "database_name" {
  type        = string
  description = "The name for the new PostgreSQL database."
  default     = "appdb"
}

variable "database_user" {
  type        = string
  description = "The username for the new PostgreSQL user."
  default     = "appuser"
}

variable "kubernetes_namespace" {
  type        = string
  description = "The Kubernetes namespace where the secret will be created."
  default     = "default"
}
