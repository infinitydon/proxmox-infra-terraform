provider "kubernetes" {
  alias = "centralK0smotronCluster"
}

data "kubernetes_secret" "kubeconfig" {
  provider = kubernetes.centralK0smotronCluster
  metadata {
    name      = var.workload_kubeconfig_secret_name
    namespace = var.workload_kubeconfig_ns
  }
}

locals {
  kubeconfig = yamldecode(data.kubernetes_secret.kubeconfig.data["value"])
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