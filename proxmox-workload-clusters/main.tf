module "workload_cluster" {
source = "./module"

providers = {
 kubernetes.centralK0smotronCluster = kubernetes.centralK0smotronCluster
 kubernetes.workloadCluster  = kubernetes.workloadCluster
 helm.workloadCluster  = helm.workloadCluster
}

proxmox_api_url = var.proxmox_api_url
proxmox_host_node    = var.proxmox_host_node
boot_disk_storage_pool    = var.boot_disk_storage_pool
ssh_public_key = var.ssh_public_key
snippets_storage_pool = var.snippets_storage_pool
vm_name  = var.vm_name
vm_identifier   =  var.vm_identifier
os_template_id = var.os_template_id
vm_memory = var.vm_memory
vm_cpu_cores = var.vm_cpu_cores
github_org = var.github_org
github_repository = var.github_repository
virtual_environment_username = var.virtual_environment_username
virtual_environment_password = var.virtual_environment_password
workload_join_token_secret_name = var.workload_join_token_secret_name
workload_kubeconfig_secret_name = var.workload_kubeconfig_secret_name
workload_kubeconfig_ns = var.workload_kubeconfig_ns
}