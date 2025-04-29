# Module to create Proxmox VMs using cloud-init
module "my_vms" {
  source = "../modules/proxmox_cloudinit_vm"

  # General VM configuration
  vm_count       = var.vm_count       # Number of VMs to create
  vm_name        = var.vm_name        # Base name for the VMs
  vm_description = var.vm_description # Description for the VMs
  target_node    = var.target_node    # Proxmox node where the VMs will be created
  clone_template = var.clone_template # Template to clone for the VMs

  # CPU and memory configuration
  cores   = var.cores   # Number of CPU cores per VM
  sockets = var.sockets # Number of CPU sockets per VM
  vcpus   = var.vcpus   # Number of virtual CPUs per VM
  memory  = var.memory  # Amount of memory (in MB) per VM

  # Disk configuration
  cloudinit_storage = var.cloudinit_storage # Storage for cloud-init configuration
  disk_size         = var.disk_size         # Disk size (in GB) for the VM
  disk_cache        = var.disk_cache        # Disk cache mode (e.g., "writeback")
  disk_storage      = var.disk_storage      # Storage location for the VM disk
  disk_replicate    = var.disk_replicate    # Whether to replicate the disk (true/false)

  # Network configuration
  network_model  = var.network_model  # Network model (e.g., "virtio")
  network_bridge = var.network_bridge # Network bridge to attach the VM to
  network_tag    = var.network_tag    # VLAN tag for the network
  ipconfig0      = var.ipconfig0      # IP configuration for the VM (e.g., "ip=192.168.1.100/24,gw=192.168.1.1")

  # Cloud-init user configuration
  ciuser         = var.ciuser                         # Username for the VM
  cipassword     = var.cipassword                     # Password for the VM user
  ssh_public_key = file("${path.module}/adrilab.pub") # Path to the SSH public key file
}