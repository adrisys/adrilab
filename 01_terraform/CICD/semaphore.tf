# Module to create Proxmox VMs using cloud-init
module "semaphore_vm_qemu" {
  source = "../modules/proxmox_cloudinit_vm"

  vm_count       = 1
  vm_name        = "semaphore"
  vm_description = "Semaphore CI/CD"
  target_node    = "pve"
  clone_template = "ubuntu-template-24.04-LTS"

  cores   = 2
  sockets = 1
  vcpus   = 0
  memory  = 2048

  cloudinit_storage = "local-lvm"
  disk_size         = 32
  disk_cache        = "writeback"
  disk_storage      = "local-lvm"
  disk_replicate    = true

  network_model  = "virtio"
  network_bridge = "vmbr0"
  network_tag    = 70

  # Use an IP address with an incrementing last octet based on count
  ip_base    = "10.0.70"   # Base IP (first three octets)
  ip_start   = 20          # Starting value for the last octet
  ip_netmask = "24"        # Subnet mask
  ip_gateway = "10.0.70.1" # Gateway IP

  ciuser     = "adri"
  cipassword = "adri"

  ssh_public_key = file("${path.module}/adrilab.pub")
  tags           = ["servers"]
}
