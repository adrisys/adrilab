# Kubernetes Control Plane VM
module "Midnight_preview" {
  source = "./modules/proxmox_cloudinit_vm"

  # VM Configuration
  vm_count       = 1
  vm_name        = ["night.lan"]
  vm_description = "Midnight"
  target_node    = var.target_node
  clone_template = var.clone_template
  vm_state       = "stopped"

  # Resource Allocation
  cores   = var.cores
  sockets = var.sockets
  vcpus   = var.vcpus
  memory  = var.midnight_memory

  # Storage Configuration
  cloudinit_storage = var.cloudinit_storage
  disk_size         = var.disk_size_kubeadm
  disk_cache        = var.disk_cache
  disk_storage      = var.disk_storage
  disk_replicate    = var.disk_replicate

  # Network Configuration
  network_model  = var.network_model
  network_bridge = var.network_bridge
  network_tag    = var.network_tag

  # IP Configuration
  ip_base    = var.ip_base
  ip_start   = var.ip_midnight_preview
  ip_netmask = var.ip_netmask
  ip_gateway = var.ip_gateway

  # Authentication & Access
  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = var.ssh_public_key

  # Metadata
  tags = var.tags

  # Protection
  protection = false
}