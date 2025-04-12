variable "zone" {
    description = "The Exoscale zone to create the SKS cluster."
    type        = string
    default     = "at-vie-2"
}

variable "instance_type" {
    description = "The instance type for the SKS nodepool."
    type        = string
    default     = "standard.small"
}

variable "kubernetes_version" {
    description = "The Kubernetes version for the SKS cluster."
    type        = string
    default     = "1.32.3"
  
}

variable "cluster_name" {
    description = "The name of the SKS cluster."
    type        = string
    default     = "sks-cluster"
}
variable "nodepool_name" {
    description = "The name of the SKS nodepool."
    type        = string
    default     = "sks-nodepool"
}
variable "nodepool_size" {
    description = "The size of the SKS nodepool."
    type        = number
    default     = 3
}

variable "service_level" {
    description = "The service level for the SKS cluster."
    type        = string
    default     = "starter"
}