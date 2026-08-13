resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
}


resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.0"

  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP" 
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]
}

resource "helm_release" "monitoring" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.21.0"

  timeout          = 600
  create_namespace = false

  values = [
    yamlencode({
      grafana = {
        service = {
          type = "ClusterIP"
        }
      }

      prometheus = {
        service = {
          type = "ClusterIP"
        }
      }

      alertmanager = {
        config = {
          route = {
            group_by = ["alertname"]
            receiver = "teams"
            routes = [
              {
                match = {
                  alertname = "HighTraffic"
                }
                receiver = "teams"
              }
            ]
          }
          receivers = [
            {
              name = "teams"
              webhook_configs = [
                {
                  url = "http://prometheus-msteams.monitoring.svc.cluster.local:2000/alertmanager"
                }
              ]
            }
          ]
        }
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}

resource "helm_release" "prometheus_msteams" {
  name       = "prometheus-msteams"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = "https://prometheus-msteams.github.io/prometheus-msteams/"
  chart      = "prometheus-msteams"
  
  wait             = false
  timeout          = 600
  create_namespace = false

  values = [
    yamlencode({
      connectors = [
        {
          alertmanager = var.teams_webhook_url
        }
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}
