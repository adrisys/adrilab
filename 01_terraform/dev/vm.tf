# Module to create Proxmox VMs using cloud-init
module "my_vms" {
  source = "../modules/proxmox_cloudinit_vm"

  vm_count       = var.vm_count
  vm_name        = var.vm_name
  vm_description = var.vm_description
  target_node    = var.target_node
  clone_template = var.clone_template

  cores   = var.cores
  sockets = var.sockets
  vcpus   = var.vcpus
  memory  = var.memory

  cloudinit_storage = var.cloudinit_storage
  disk_size         = var.disk_size
  disk_cache        = var.disk_cache
  disk_storage      = var.disk_storage
  disk_replicate    = var.disk_replicate

  network_model  = var.network_model
  network_bridge = var.network_bridge
  network_tag    = var.network_tag
  ipconfig0      = var.ipconfig0

  ciuser         = var.ciuser
  cipassword     = var.cipassword
  ssh_public_key = file("${path.module}/adrilab.pub")
}

output "vm_ips" {
  value = module.my_vms.vm_ips
}