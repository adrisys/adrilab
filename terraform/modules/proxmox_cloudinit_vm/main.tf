terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}


resource "proxmox_vm_qemu" "cloudinit_vm" {
  count = var.vm_count
  # Handle vm_name as either string or list of strings
  name = can(tolist(var.vm_name)) && length(var.vm_name) > count.index ? var.vm_name[count.index] : (
    can(tostring(var.vm_name)) ? (
      var.vm_count > 1 ? "${var.vm_name}-${count.index + 1}" : var.vm_name
    ) : "vm-${count.index + 1}"
  )
  desc        = var.vm_description
  target_node = var.target_node
  #  clone       = var.clone_template == "debian-template-12" ? var.clone_template : null
  clone    = var.clone_template
  vm_state = var.vm_state
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.cores
  sockets  = var.sockets
  vcpus    = var.vcpus
  memory   = var.memory
  scsihw   = "virtio-scsi-pci"
  tags     = join(",", var.tags) # Convert list to comma-separated string

  # Use custom cloud-init file if provided 
  cicustom = var.custom_cloud_init_file != "" ? "user=${var.custom_cloud_init_file}" : null

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.cloudinit_storage
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          size      = var.disk_size
          cache     = var.disk_cache
          storage   = var.disk_storage
          replicate = var.disk_replicate
        }
      }
    }
  }

  network {
    id     = 0
    model  = var.network_model
    bridge = var.network_bridge
    tag    = var.network_tag
  }

  boot      = "order=scsi0"
  ipconfig0 = "ip=${var.ip_base}.${var.ip_start + count.index}/${var.ip_netmask},gw=${var.ip_gateway}"
  sshkeys   = var.ssh_public_key
  serial {
    id   = 0
    type = "socket"
  }

  ciuser     = var.ciuser
  cipassword = var.cipassword

  onboot     = var.onboot
  protection = var.protection

  lifecycle {
    ignore_changes = [clone]
  }
}
