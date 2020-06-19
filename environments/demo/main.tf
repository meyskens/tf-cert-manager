module "demo_cluster" {
  source        = "../../modules/kubernetes"
  cluster_name  = "demo"
  is_cluster_up = false
}