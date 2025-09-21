variable "kubeconfig" {
  type    = string
  default = "~/.kube/config"
}

variable "namespace" {
  type    = string
  default = "payments"
}

variable "grafana_user" {
  type      = string
  sensitive = true
}

variable "grafana_password" {
  type      = string
  sensitive = true
}
