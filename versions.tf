terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "= 3.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.12.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "= 3.4.0"
    }
  }
  required_version = ">= 1.6.2"
}
