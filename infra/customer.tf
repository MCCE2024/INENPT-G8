# Terraform configuration for customer

module "customer-db" {
  # Path to the module directory
  source = "./modules/tenant-db"

  # Pass the required variables from our service to the module
  dbaas_service_name = exoscale_dbaas.pg.name
  dbaas_service_zone = exoscale_dbaas.pg.zone

  # (Optional) Override default names
  database_name          = "customer"
  database_user          = "customer-user"
  kubernetes_namespace   = "customer"
}
