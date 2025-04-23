terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8" # or latest available
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://pve.adrilab.com/api2/json"
  pm_user         = "root@pam"
  pm_password     = "Estartus1!"
  pm_tls_insecure = true
  
}


resource "proxmox_vm_qemu" "my_vm" {
  name        = "ubuntu-tf-test"
  target_node = "pve"
  clone       = "ubuntu-template"
  full_clone  = true  # optional, but ensures it's independent
  cores       = 2
  memory      = 2048

  # Required to ensure proper boot device setup
  boot        = "order=scsi0"
  bootdisk    = "scsi0"

  # Network config
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # IP config for cloud-init
  ipconfig0 = "ip=dhcp"

  # SSH key (optional if you set one in the template already)
  sshkeys = file("~/.ssh/id_rsa.pub")

  # Optional disk resize
  disk {
    slot    = "scsi0"
    size    = "40G"
    type    = "disk"
    storage = "local-lvm"
  }
}
