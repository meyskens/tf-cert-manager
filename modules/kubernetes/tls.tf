resource "kubernetes_manifest" "acme_issuer" {
  count = var.is_cluster_up ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind" = "Issuer"
    "metadata" = {
      "name" = "le-staging"
      "namespace" = "default"
    }
    "spec" = {
      "acme" = {
          "email" = var.contact_email
          "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
          "privateKeySecretRef" = {
              "name" = "le-staging-account"
          }
          "solvers" = [
              {
                "http01" = {
                  "ingress" = {
                    "class" = "nginx"
                  }
                }
              }
          ]
      }
    }
  }
}

/*
resource "kubernetes_manifest" "test-configmap" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "v1"
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "test-config"
      "namespace" = "default"
    }
    "data" = {
      "foo" = "bar"
    }
  }
}
*/