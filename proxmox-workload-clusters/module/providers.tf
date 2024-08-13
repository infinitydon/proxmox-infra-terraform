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
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
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

provider "kubernetes" {
  alias = "centralK0smotronCluster"
}

provider "kubernetes" {
  alias = "workloadCluster"

  host                   = local.kubeconfig.clusters[0].cluster.server
  client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
  client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
}

provider "helm" {
  alias = "workloadCluster"
  kubernetes {
  host                   = local.kubeconfig.clusters[0].cluster.server
  client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
  client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  }
}