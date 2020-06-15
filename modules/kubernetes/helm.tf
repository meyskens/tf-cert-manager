provider "helm" {
  kubernetes {
    host = kind.cluster.endpoint

    client_certificate     = kind.cluster.client_certificate
    client_key             = kind.cluster.client_key
    cluster_ca_certificate = kind.cluster.cluster_ca_certificate
  }
}
