variable "vm_name" {
    description = "Name of the VM"
    type = string
}

variable "vm_identifier" {
    description = "Proxmox VM ID number"
    type = number
}

variable "vm_memory" {
    description = "The amount of memory in MiB to give the VMs."
    type = number
    default = 16384
}

variable "vm_cpu_cores" {
    description = "The number of CPU cores to give the VMs."
    type = number
    default = 16 
}

variable "os_template_id" {
    description = "The template that the VMs will be cloned from."
    type = string
}

variable "boot_disk_storage_pool" {
    description = "The name of the storage pool where boot disks for the cluster nodes will be stored."
    type = string
    default = "ebenezer-stor1"
}

variable "node_disk_size" {
    description = "The size of the boot disks. A numeric string with G, M, or K appended ex: 512M or 32G."
    type = string
    default = "100"
}

variable "config_network_bridge" {
    description = "The name of the network bridge on the Proxmox host that will be used for the configuration network."
    type = string
    default = "vmbr1"
}

variable "proxmox_api_url" {
    description = "The URL for the Proxmox API."
    type = string
}

variable "proxmox_host_node" {
    description = "The proxmox host node."
    type = string  
}

variable "virtual_environment_username" {
    description = "The proxmox username."
    type = string  
}

variable "virtual_environment_password" {
    description = "The proxmox password."
    type = string  
}

variable "ssh_public_key" {
  description = "SSH public key"
  type = string
}

variable "snippets_storage_pool" {
  description = "Storage pool that support snippets"
  type = string
}

variable "tags" {
    description = "TAG values"
    default = ["k0s", "nephio-k8s"]
}

variable "ssh_username" {
  type = string
  default = "ubuntu"
}

variable "workload_kubeconfig_secret_name" {
  description = "The workload-cluster controlplane kubeconfig secret name"
  type = string
}

variable "workload_kubeconfig_ns" {
  description = "k8s namespace in the MGMT cluster where the workload-cluster controlplane is located"
  type = string
}

variable "workload_join_token_secret_name" {
  description = "k8s workload k0smotron join secret in the MGMT cluster where the workload-cluster controlplane is located"
  type = string
}

variable "github_org" {
  type    = string
}

variable "github_repository" {
  type    = string
}