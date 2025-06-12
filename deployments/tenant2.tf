# Terraform configuration for tenant2

module "tenant_db_tenant2" {
  source = "../modules/tenant-db"

  # --- Tenant Specific Variables ---
  # Replace these with the actual variables required by your tenant-db module.
  # For example:
  # tenant_name    = "tenant2"
  # database_size  = "small" 
  # region         = "us-east-1"

  tags = {
    Tenant      = "tenant2"
    Environment = "production"
  }
}
