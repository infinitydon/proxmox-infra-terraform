resource "kubernetes_namespace" "flux_system" {
  provider = kubernetes.workloadCluster
  metadata {
    name = "flux-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }   
}

resource "kubernetes_secret" "github_deploy_key" {
  provider = kubernetes.workloadCluster
  depends_on = [kubernetes_namespace.flux_system]
  metadata {
    name      = "${var.github_repository}-gh-key"
    namespace = "flux-system"
  }

  data = {
    ssh-privatekey = local.github_ssh_key
  }

  type = "kubernetes.io/ssh-auth"
}

resource "helm_release" "flux_operator" {
  provider = helm.workloadCluster
  depends_on = [kubernetes_namespace.flux_system]

  name       = "flux-operator"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
}

resource "helm_release" "flux_instance" {
  provider = helm.workloadCluster
  depends_on = [helm_release.flux_operator,
               kubernetes_secret.github_deploy_key
               ]
  
  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"

  // Configure the Flux distribution.
  set {
    name  = "instance.distribution.version"
    value = "2.x"
  }
  set {
    name  = "instance.distribution.registry"
    value = "ghcr.io/fluxcd"
  }

  // Configure Flux Git sync.
  set {
    name  = "instance.sync.kind"
    value = "GitRepository"
  }
  set {
    name  = "instance.sync.url"
    value = "https://github.com/${var.github_org}/${var.github_repository}.git"
  }
  set {
    name  = "instance.sync.path"
    value = "/"
  }
  set {
    name  = "instance.sync.ref"
    value = "refs/heads/main"
  }
  set {
    name  = "instance.sync.pullSecret"
    value = "${var.github_repository}-gh-key"
  }
}