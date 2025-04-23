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
  name        = "terraform-vm"
  target_node = "pve"
  clone       = "ubuntu-template"

  # ipconfig0 = "ip=10.0.10.111/24,gw=10.0.10.1"

  # os_type = "cloud-init"
  # ciuser  = "ubuntu"
  # cipassword = "securepassword"

  # sshkeys = file("~/.ssh/id_rsa.pub")
}
