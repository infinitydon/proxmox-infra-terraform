data "kubernetes_secret" "k0smotron_join_token" {
  provider = kubernetes.centralK0smotronCluster
  metadata {
    name      = var.workload_join_token_secret_name
    namespace = "k0smotron"
  }
}

data "kubernetes_secret" "kubeconfig" {
  provider = kubernetes.centralK0smotronCluster
  metadata {
    name      = var.workload_kubeconfig_secret_name
    namespace = var.workload_kubeconfig_ns
  }
}

data "kubernetes_secret" "workload_github_ssh_key" {
  provider = kubernetes.centralK0smotronCluster
  metadata {
    name      = "${var.github_repository}-gh-key"
    namespace = "flux-system"
  }
}

locals {
  kubeconfig = yamldecode(data.kubernetes_secret.kubeconfig.data["value"])
  decoded_token = data.kubernetes_secret.k0smotron_join_token.data["token"]
  github_ssh_key = data.kubernetes_secret.workload_github_ssh_key.data["ssh-privatekey"]
}