provider "exoscale" {}

# Create a new SKS cluster
resource "exoscale_sks_cluster" "sks_cluster" {
  zone = var.zone
  name = var.cluster_name
  version = var.kubernetes_version
  service_level = var.service_level
}

# Create a new SKS nodepool
resource "exoscale_sks_nodepool" "my_sks_nodepool" {
  cluster_id         = exoscale_sks_cluster.sks_cluster.id
  zone               = exoscale_sks_cluster.sks_cluster.zone
  name               = var.nodepool_name
  instance_type      = var.instance_type
  size               = var.nodepool_size
}

output "sks_cluster_endpoint" {
  value = exoscale_sks_cluster.sks_cluster.endpoint
}