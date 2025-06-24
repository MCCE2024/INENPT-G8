# Terraform configuration for test-tenant

module "test-tenant-db" {
  # Path to the module directory
  source = "./modules/tenant-db"

  # Pass the required variables from our service to the module
  dbaas_service_name = exoscale_dbaas.pg.name
  dbaas_service_zone = exoscale_dbaas.pg.zone

  PGDB_PW = var.PGDB_PW
  PGDB_ADMIN = var.PGDB_ADMIN

  # (Optional) Override default names
  database_name          = "test-tenant"
  database_user          = "test-tenant-user"
  kubernetes_namespace   = "test-tenant"
}
