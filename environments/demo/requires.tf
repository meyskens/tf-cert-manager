terraform {
  required_version = ">= 0.12.26"
}

provider "kubernetes-alpha" {}

provider "kind" {}

provider "helm" {}

provider "kubernetes" {}