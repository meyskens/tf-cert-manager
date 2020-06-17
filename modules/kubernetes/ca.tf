resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "terraform-ca"
    organization = "Jetstack ltd."
  }

  validity_period_hours = 8766

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  is_ca_certificate = true
}

resource "kubernetes_secret" "ca" {
  metadata {
    name = "ca"
    namespace = "default"
  }

  data = {
    "tls.crt" = tls_self_signed_cert.ca.cert_pem
    "tls.key" = tls_private_key.ca.private_key_pem
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_manifest" "ca_issuer" {
  count    = var.is_cluster_up ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "ca"
      "namespace" = "default"
    }
    "spec" = {
      "ca" = {
        "secretName"  = kubernetes_secret.ca.metadata[0].name
      }
    }
  }
}

