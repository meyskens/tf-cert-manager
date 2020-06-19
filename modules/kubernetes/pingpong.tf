resource "kubernetes_deployment" "ping" {
  count = var.is_cluster_up ? 1 : 0
  metadata {
    name      = "ping"
    namespace = "default"
    labels = {
      app = "ping"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ping"
      }
    }

    template {
      metadata {
        labels = {
          app = "ping"
        }
      }

      spec {
        volume {
          name = "tls"
          secret {
            secret_name = "ping-tls"
          }

        }
        container {
          image = "maartje/tls-ping-pong:2d1f1a81edf639ec2b1221f0cb7d84eb01bcae16"
          name  = "pingpong"
          command = [
            "pingpong",
            "-endpoint=https://pong.default.svc.cluster.local:8443/ping",
            "-ca-file=/etc/ssl/private/ca.crt",
            "-cert-file=/etc/ssl/private/tls.crt",
            "-key-file=/etc/ssl/private/tls.key",
          ]

          volume_mount {
            mount_path = "/etc/ssl/private"
            name       = "tls"
            read_only  = true
          }

          port {
            container_port = 8443
            name           = "internal-https"
          }

          port {
            container_port = 9443
            name           = "external-https"
          }

        }
      }
    }
  }
}

resource "kubernetes_deployment" "pong" {
  count = var.is_cluster_up ? 1 : 0
  metadata {
    name      = "pong"
    namespace = "default"
    labels = {
      app = "pong"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "pong"
      }
    }

    template {
      metadata {
        labels = {
          app = "pong"
        }
      }

      spec {
        volume {
          name = "tls"
          secret {
            secret_name = "pong-tls"
          }

        }
        container {
          image = "maartje/tls-ping-pong:2d1f1a81edf639ec2b1221f0cb7d84eb01bcae16"
          name  = "pingpong"
          command = [
            "pingpong",
            "-endpoint=https://ping.default.svc.cluster.local:8443/ping",
            "-ca-file=/etc/ssl/private/ca.crt",
            "-cert-file=/etc/ssl/private/tls.crt",
            "-key-file=/etc/ssl/private/tls.key",
          ]

          volume_mount {
            mount_path = "/etc/ssl/private"
            name       = "tls"
            read_only  = true
          }

          port {
            container_port = 8443
            name           = "internal-https"
          }

          port {
            container_port = 9443
            name           = "external-https"
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "ping" {
  count = var.is_cluster_up ? 1 : 0
  metadata {
    name      = "ping"
    namespace = "default"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.ping[0].metadata.0.labels.app}"
    }

    port {
      name        = "internal-https"
      port        = 8443
      target_port = "internal-https"
    }

    port {
      name        = "external-https"
      port        = 9443
      target_port = "external-https"
      node_port   = 30443
    }



    type = "NodePort"
  }
}


resource "kubernetes_service" "pong" {
  count = var.is_cluster_up ? 1 : 0
  metadata {
    name      = "pong"
    namespace = "default"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.pong[0].metadata.0.labels.app}"
    }

    port {
      name        = "internal-https"
      port        = 8443
      target_port = "internal-https"
    }

    port {
      name        = "external-https"
      port        = 9443
      target_port = "external-https"
      node_port   = 31443
    }
    type = "NodePort"
  }
}


resource "kubernetes_manifest" "ping_cert" {
  count    = var.is_cluster_up ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "ping"
      "namespace" = "default"
    }
    "spec" = {
      "duration"    = "1h"
      "renewBefore" = "30m"
      "secretName"  = "ping-tls"
      "dnsNames" = [
        "ping.default.svc.cluster.local"
      ]
      "issuerRef" = {
        "kind" = "Issuer"
        "name" = kubernetes_manifest.ca_issuer[0].manifest.metadata.name
      }
      "usages" = [
        "digital signature",
        "key encipherment",
        "server auth",
        "client auth",
      ]
    }
  }
}

resource "kubernetes_manifest" "pong_cert" {
  count    = var.is_cluster_up ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha2"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "pong"
      "namespace" = "default"
    }
    "spec" = {
      "duration"    = "1h"
      "renewBefore" = "30m"
      "secretName"  = "pong-tls"
      "dnsNames" = [
        "pong.default.svc.cluster.local"
      ]
      "issuerRef" = {
        "kind" = "Issuer"
        "name" = kubernetes_manifest.ca_issuer[0].manifest.metadata.name
      }
      "usages" = [
        "digital signature",
        "key encipherment",
        "server auth",
        "client auth",
      ]
    }
  }
}
