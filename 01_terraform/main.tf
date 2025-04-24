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

resource "proxmox_vm_qemu" "cloud_vm" {
  name        = "my-cloudinit-vm"
  target_node = "pve"
  clone       = "ubuntu-template"  # Template VM name or ID
  full_clone  = true

  cores       = 2
  memory      = 2048

  os_type     = "cloud-init"

  disk {
    slot     = "scsi0"
    size     = "40G"
    type     = "disk"
    storage  = "local-lvm"
    iothread = true
  }

  network {
    id      = 0
    model   = "virtio"
    bridge  = "vmbr0"
  }

  # Cloud-init config
  ipconfig0 = "ip=dhcp"
  sshkeys   = file("~/.ssh/id_rsa.pub")
  ciuser    = "adrian"
  cicustom  = ""  # Optional, for custom cloud-init ISO
}