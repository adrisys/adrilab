resource "proxmox_vm_qemu" "cloudinit_vm" {
  count       = var.vm_count
  name        = "${var.vm_name}-${count.index + 1}"
  desc        = var.vm_description
  target_node = var.target_node
  clone       = var.clone_template

  agent   = 1
  os_type = "cloud-init"
  cores   = var.cores
  sockets = var.sockets
  vcpus   = var.vcpus
  memory  = var.memory
  scsihw  = "virtio-scsi-pci"

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
  ipconfig0 = var.ipconfig0
  sshkeys   = file("${path.module}/adrilab.pub")


  serial {
    id   = 0
    type = "socket"
  }

  ciuser     = var.ciuser
  cipassword = var.cipassword
}