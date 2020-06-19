module "demo_cluster" {
  source        = "../../modules/kubernetes"
  cluster_name  = "demo"
  contact_email = "maartje+tfcm@eyskens.me"
  is_cluster_up = true
}