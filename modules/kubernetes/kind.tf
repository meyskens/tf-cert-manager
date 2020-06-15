resource "kind" "cluster" {
  name = "kind-${var.cluster_name}"
}