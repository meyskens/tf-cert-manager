module "demo_cluster" {
  source       = "../../modules/kubernetes"
  cluster_name = "demo"
  contact_email = "demo@example.com"
  is_cluster_up = true
}