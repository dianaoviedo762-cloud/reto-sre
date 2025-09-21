# Namespace para monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Secret para credenciales de Grafana (se referencian en values.yaml)
resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = var.namespace
  }
  data = {
    admin-user     = base64encode(var.grafana_user)
    admin-password = base64encode(var.grafana_password)
  }
  type = "Opaque"
}

# Helm release: kube-prometheus-stack
resource "helm_release" "kube_prometheus_stack" {
  depends_on = [kubernetes_namespace.monitoring, kubernetes_secret.grafana_admin
  ]

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    file("${path.module}/values/kube-prometheus-values.yaml")
  ]

  # esto hace que Helm instale los CRDs automáticamente
  set {
    name  = "installCRDs" # Esto deja que Helm cree los CRDs auto(en vez de
    value = "true"
  }

  wait    = false
  force_update = true
  timeout = 600 # esto da 10min para instalar (ya que a veces grafana y prometeus tardan mucho)
  atomic  = false # si falla la instalación, revierte(true)
}


#Helm release: otel_collector
resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = var.namespace

  values = [file("${path.module}/values/otel-values.yaml")]

  wait    = false      # Terraform no esperará a que los pods estén listos
  timeout = 600
}
