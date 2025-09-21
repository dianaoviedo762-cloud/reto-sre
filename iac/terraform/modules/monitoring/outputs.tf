output "grafana_secret" {
  value     = kubernetes_secret.grafana_admin.metadata[0].name
  sensitive = true
}

output "namespace" {
  value = var.namespace
}
