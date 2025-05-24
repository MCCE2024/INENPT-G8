# Cluster region
variable "zone" {
  description = "The Exoscale zone to create the SKS cluster."
  type        = string
  default     = "at-vie-2"
}

# Node instance size/type
variable "instance_type" {
  description = "The instance type for the SKS nodepool."
  type        = string
  default     = "standard.small"
}

# K8s version
variable "kubernetes_version" {
  description = "The Kubernetes version for the SKS cluster."
  type        = string
  default     = "1.33.0"
}

# Name of the cluster
variable "cluster_name" {
  description = "The name of the SKS cluster."
  type        = string
  default     = "sks-cluster"
}

# Name of the nodepool
variable "nodepool_name" {
  description = "The name of the SKS nodepool."
  type        = string
  default     = "sks-nodepool"
}

# Number of nodes in the nodepool
variable "nodepool_size" {
  description = "The size of the SKS nodepool."
  type        = number
  default     = 3
}

# Service level for the SKS cluster (e.g., starter, pro)
variable "service_level" {
  description = "The service level for the SKS cluster."
  type        = string
  default     = "starter"
}

# Password for the appuser database user (should be provided securely)
variable "apgdb_pw" {
  description = "Password for the appuser database user"
  type        = string
  sensitive   = true
}
