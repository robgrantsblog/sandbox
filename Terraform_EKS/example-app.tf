# Illustrative example: a minimal app exposed at var.domain_name via ALB + external-dns.
# Delete this file (or replace it with your real app's manifests) once you have something to deploy.

resource "kubernetes_config_map" "example" {
  metadata {
    name      = "example-app-html"
    namespace = "default"
  }

  data = {
    "index.html" = "<html><body><h1>Hello from EKS!</h1></body></html>"
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name      = "example-app"
    namespace = "default"
    labels    = { app = "example-app" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "example-app" }
    }

    template {
      metadata {
        labels = { app = "example-app" }
      }

      spec {
        # Non-root, no admin API access from the app's pods
        automount_service_account_token = false

        container {
          name  = "nginx"
          image = "public.ecr.aws/nginx/nginx:stable"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          security_context {
            run_as_non_root            = true
            run_as_user                = 101 # official nginx image's unprivileged "nginx" user
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
              # needed to bind port 80 as a non-root user
              add = ["NET_BIND_SERVICE"]
            }
          }

          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
          }

          # Writable scratch space required by nginx since the root filesystem is read-only
          volume_mount {
            name       = "var-cache-nginx"
            mount_path = "/var/cache/nginx"
          }

          volume_mount {
            name       = "var-run"
            mount_path = "/var/run"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "html"

          config_map {
            name = kubernetes_config_map.example.metadata[0].name
          }
        }

        volume {
          name = "var-cache-nginx"
          empty_dir {}
        }

        volume {
          name = "var-run"
          empty_dir {}
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "kubernetes_service" "example" {
  metadata {
    name      = "example-app"
    namespace = "default"
  }

  spec {
    selector = { app = "example-app" }
    # target-type "ip" on the Ingress routes directly to pod IPs, so ClusterIP is sufficient here
    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "example" {
  metadata {
    name      = "example-app"
    namespace = "default"

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTP" = 80 }, { "HTTPS" = 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate_validation.this.certificate_arn
      "alb.ingress.kubernetes.io/wafv2-acl-arn"   = aws_wafv2_web_acl.example.arn
      "external-dns.alpha.kubernetes.io/hostname" = var.domain_name
    }
  }

  spec {
    rule {
      host = var.domain_name

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.example.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}
