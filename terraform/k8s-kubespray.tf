# Kubernetes Control Plane VM
module "proxmox_vm_k8s_cp" {
  source = "./modules/proxmox_cloudinit_vm"

  # VM Configuration
  vm_count       = 1
  vm_name        = ["master.lan"]
  vm_description = "Kubernetes Control Plane"
  target_node    = var.target_node
  clone_template = var.clone_template
  vm_state       = "running"

  # Resource Allocation
  cores   = var.cores
  sockets = var.sockets
  vcpus   = var.vcpus
  memory  = var.memory

  # Storage Configuration
  cloudinit_storage = var.cloudinit_storage
  disk_size         = var.disk_size
  disk_cache        = var.disk_cache
  disk_storage      = var.disk_storage
  disk_replicate    = var.disk_replicate

  # Network Configuration
  network_model  = var.network_model
  network_bridge = var.network_bridge
  network_tag    = var.network_tag

  # IP Configuration
  ip_base    = var.ip_base
  ip_start   = var.control_plane_ip_start_kubespray
  ip_netmask = var.ip_netmask
  ip_gateway = var.ip_gateway

  # Authentication & Access
  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = var.ssh_public_key

  # Metadata
  tags = var.tags
}

# Kubernetes Worker Nodes
module "proxmox_vm_k8s_nodes" {
  source = "./modules/proxmox_cloudinit_vm"

  # VM Configuration
  vm_count       = 2
  vm_name        = ["worker1.lan", "worker2.lan"]
  vm_description = "Kubernetes Worker Node"
  target_node    = var.target_node
  clone_template = var.clone_template
  vm_state       = "running"

  # Resource Allocation
  cores   = var.cores
  sockets = var.sockets
  vcpus   = var.vcpus
  memory  = var.memory

  # Storage Configuration
  cloudinit_storage = var.cloudinit_storage
  disk_size         = var.disk_size_kubespray
  disk_cache        = var.disk_cache
  disk_storage      = var.disk_storage
  disk_replicate    = var.disk_replicate

  # Network Configuration
  network_model  = var.network_model
  network_bridge = var.network_bridge
  network_tag    = var.network_tag

  # IP Configuration
  ip_base    = var.ip_base
  ip_start   = var.worker_ip_start_kubespray
  ip_netmask = var.ip_netmask
  ip_gateway = var.ip_gateway

  # Authentication & Access
  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = var.ssh_public_key

  # Metadata
  tags = var.tags

  # Cloud-init Configuration
  custom_cloud_init_file = ""
}