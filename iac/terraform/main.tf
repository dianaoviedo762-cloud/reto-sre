resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  create_namespace = true

  # valores recomendados en un archivo yaml
  # Pero aquí apunta a "." y ahí no está mi helm-values/kube-prometheus-values.yaml, por lo tanto paso esta referencia al módulo (ver archivo iac/terraform/modules/monitoring/main.tf
  #values = [file("${path.module}/helm-values/kube-prom-values.yaml")]
}

  #Expo de modulos
module "monitoring" {
  source = "./modules/monitoring"

  namespace        = "monitoring"
  grafana_user     = var.grafana_user
  grafana_password = var.grafana_password
  chart_version    = "65.5.0"

  providers = {
    kubernetes = kubernetes
    helm = helm
    #kubernetes = kubernetes.minikube --- No sería necesario porque no tengo alias de "minikube" configurados en el provider
    #helm       = helm.minikube
  }
}
