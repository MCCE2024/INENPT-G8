# Use the default Exoscale security group for the nodepool
data "exoscale_security_group" "default" {
  name = "default"
}

# Create a new SKS cluster in Exoscale
resource "exoscale_sks_cluster" "sks_cluster" {
  zone          = var.zone                 # Region/zone for the cluster
  name          = var.cluster_name         # Name of the cluster
  version       = var.kubernetes_version   # Kubernetes version
  service_level = var.service_level        # Cluster tier (e.g., starter)
}

resource "exoscale_sks_kubeconfig" "sks_kubeconfig" {
  zone                  = exoscale_sks_cluster.sks_cluster.zone
  cluster_id            = exoscale_sks_cluster.sks_cluster.id
  user                  = "kubernetes-admin"
  groups                = ["system:masters"]
  ttl_seconds           = 3600
  early_renewal_seconds = 300
}

resource "local_sensitive_file" "kubeconfig_file" {
  filename        = "kubeconfig"
  content         = exoscale_sks_kubeconfig.sks_kubeconfig.kubeconfig
  file_permission = "0600"
}

# Create a custom security group specifically for the nodepool
resource "exoscale_security_group" "sks_security_group" {
  name = "sks-security-group"
}

# Allow TCP traffic for Kubelet between nodes
resource "exoscale_security_group_rule" "kubelet" {
  security_group_id        = exoscale_security_group.sks_security_group.id
  description              = "Kubelet"
  type                     = "INGRESS"
  protocol                 = "TCP"
  start_port               = 10250
  end_port                 = 10250
  user_security_group_id   = exoscale_security_group.sks_security_group.id
}

# Allow Calico VXLAN UDP traffic between nodes for pod networking
resource "exoscale_security_group_rule" "calico_vxlan" {
  security_group_id        = exoscale_security_group.sks_security_group.id
  description              = "VXLAN (Calico)"
  type                     = "INGRESS"
  protocol                 = "UDP"
  start_port               = 4789
  end_port                 = 4789
  user_security_group_id   = exoscale_security_group.sks_security_group.id
}

# Public access to NodePort services (TCP)
resource "exoscale_security_group_rule" "nodeport_tcp" {
  security_group_id = exoscale_security_group.sks_security_group.id
  description       = "Nodeport TCP services"
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 30000
  end_port          = 32767
  cidr              = "0.0.0.0/0"  # Public access
}

# Public access to NodePort services (UDP)
resource "exoscale_security_group_rule" "nodeport_udp" {
  security_group_id = exoscale_security_group.sks_security_group.id
  description       = "Nodeport UDP services"
  type              = "INGRESS"
  protocol          = "UDP"
  start_port        = 30000
  end_port          = 32767
  cidr              = "0.0.0.0/0"  # Public access
}

# Create a nodepool for the SKS cluster
resource "exoscale_sks_nodepool" "sks_nodepool" {
  cluster_id          = exoscale_sks_cluster.sks_cluster.id
  zone                = exoscale_sks_cluster.sks_cluster.zone
  name                = var.nodepool_name
  instance_type       = var.instance_type
  size                = var.nodepool_size

  # Attach both the default and custom security groups
  security_group_ids = [
    data.exoscale_security_group.default.id,
    resource.exoscale_security_group.sks_security_group.id,
  ]
}

# Output the SKS API endpoint after provisioning
output "sks_cluster_endpoint" {
  value = exoscale_sks_cluster.sks_cluster.endpoint
}