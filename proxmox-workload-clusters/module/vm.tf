resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_storage_pool
  node_name    = var.proxmox_host_node

  source_raw {
    data = <<EOF
#cloud-config
disable_root: false
user: ubuntu
ssh_authorized_keys:
  - ${var.ssh_public_key}
chpasswd:
  expire: False
users:
  - default
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
package_upgrade: true
packages:
- httpie
write_files:
  - path:  /etc/netplan/ens19-cloud-init.yaml
    permissions: '0644'
    content: |
         network:
           version: 2
           renderer: networkd
           ethernets:
             ens19:
               dhcp4: false
  - path: /usr/lib/systemd/system/config-sriov.service
    permissions: '0644'
    content: |
      [Unit]
      Description=DPDK configuration
      DefaultDependencies=no
      After=network-online.target
      Before=kubelet.service
      
      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=/bin/bash /opt/dpdk/config-sriov.sh
      
      [Install]
      WantedBy=sysinit.target
  - path: /opt/dpdk/config-sriov.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
      /usr/local/bin/dpdk-devbind.py -b vfio-pci 0000:00:14.0
  - path: /etc/k0smotron-token
    permissions: '0600'
    content: |
      ${local.decoded_token}
runcmd:
  - netplan generate
  - netplan apply
  - hostnamectl set-hostname `dmesg | grep -i nephio | awk '{print $5}' | sed 's/,//g'`
  - curl -sSLf https://get.k0s.sh | K0S_VERSION=v1.30.3+k0s.0 sh
  - k0s install worker --token-file /etc/k0smotron-token
  - k0s start
  - |
    echo "Waiting for k0s worker service to be active..."
    until systemctl is-active --quiet k0sworker; do
      echo "k0s worker service is not active yet. Retrying in 5 seconds..."
      sleep 5
    done
    
    echo "k0s worker service is active."
  - wget https://github.com/DPDK/dpdk/raw/main/usertools/dpdk-devbind.py -O /usr/local/bin/dpdk-devbind.py
  - chmod +x /usr/local/bin/dpdk-devbind.py
  - sed -i 's/GRUB_CMDLINE_LINUX="/&default_hugepagesz=1GB hugepagesz=1G hugepages=4/' /etc/default/grub
  - update-grub
  - systemctl enable config-sriov.service
  - systemctl start config-sriov.service
  - reboot  
EOF

    file_name = "${var.vm_identifier}.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  vm_id = var.vm_identifier

  name        = var.vm_name
  description = "k0s VMS"

  tags        = var.tags

  node_name = var.proxmox_host_node

  smbios {
    product = var.vm_name
  }  

  agent {
    enabled = true
  }
  on_boot = false

  clone {
    retries = 3
    vm_id   = var.os_template_id
  }

  disk {
    datastore_id = var.boot_disk_storage_pool
    interface    = "scsi0"
    file_format  = "raw"
    discard      = "on"
    size         = var.node_disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  cpu {
    architecture = "x86_64"
    cores        = var.vm_cpu_cores
    type         = "host"
  }
  memory {
    dedicated = var.vm_memory
  }
  network_device {
    bridge  = var.config_network_bridge
  }

  network_device {
    bridge  = var.config_network_bridge
  }

  network_device {
    bridge  = var.config_network_bridge
  }

  network_device {
    bridge  = var.config_network_bridge
  }  

  operating_system {
    type = "l26"
  }

  serial_device {} 

  lifecycle {
    ignore_changes = [
      disk[0],
      vga,
      initialization   
    ]
  }  
}

output "ip_addresses" {
  value     = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses
}