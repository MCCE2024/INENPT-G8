# Terraform configuration for webshop2

module "webshop2-db" {
  # Path to the module directory
  source = "./modules/tenant-db"

  # Pass the required variables from our service to the module
  dbaas_service_name = exoscale_dbaas.pg.name
  dbaas_service_zone = exoscale_dbaas.pg.zone

  # (Optional) Override default names
  database_name          = "webshop2"
  database_user          = "webshop2-user"
  kubernetes_namespace   = "webshop2"
}
