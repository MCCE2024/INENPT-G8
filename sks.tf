# Create a new SKS cluster
resource "exoscale_sks_cluster" "sks_cluster" {
  zone = var.zone
  name = var.cluster_name
  version = var.kubernetes_version
  service_level = var.service_level
}

# Create a new SKS nodepool
resource "exoscale_sks_nodepool" "sks_nodepool" {
  cluster_id         = exoscale_sks_cluster.sks_cluster.id
  zone               = exoscale_sks_cluster.sks_cluster.zone
  name               = var.nodepool_name
  instance_type      = var.instance_type
  size               = var.nodepool_size
}

resource "exoscale_sks_kubeconfig" "sks_kubeconfig" {
  zone       = exoscale_sks_cluster.sks_cluster.zone
  cluster_id = exoscale_sks_cluster.sks_cluster.id
  user   = "kubernetes-admin"
  groups = ["system:masters"]
  ttl_seconds           = 3600
  early_renewal_seconds = 300
}

resource "local_sensitive_file" "kubeconfig_file" {
  filename        = "kubeconfig"
  content         = exoscale_sks_kubeconfig.sks_kubeconfig.kubeconfig
  file_permission = "0600"
}

output "sks_cluster_endpoint" {
  value = exoscale_sks_cluster.sks_cluster.endpoint
}