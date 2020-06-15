variable "cluster_name" {
  description = "Unique cluster name"
}

variable "contact_email" {
  description = "Email for ACME issuer"
}

variable "is_cluster_up" {
  description = "Is the cluster up?"
  default = false
}