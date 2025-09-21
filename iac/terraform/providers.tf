terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

# provider kubernetes (usa kubeconfig de minikube), aquí; en teoría es el único lugar donde se autentica contra el cluster
provider "kubernetes" {
  config_path = var.kubeconfig
}

# provider helm (usa mismo kubeconfig)
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}
