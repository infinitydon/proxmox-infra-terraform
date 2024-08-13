terraform {
  required_version = ">= 1.7.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.61.1"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
      configuration_aliases = [
        helm.workloadCluster
      ]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
      configuration_aliases = [
        kubernetes.centralK0smotronCluster,
        kubernetes.workloadCluster
      ]
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  insecure = true
  username = var.virtual_environment_username
  password = var.virtual_environment_password
}