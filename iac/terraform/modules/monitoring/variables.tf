variable "namespace" {
  default = "monitoring"
}

variable "grafana_user" {
  type      = string
  sensitive = true
}

variable "grafana_password" {
  type      = string
  sensitive = true
}

variable "chart_version" {
  type    = string
  default = "65.5.0" # Pendiente mirar versión exacta.
}
