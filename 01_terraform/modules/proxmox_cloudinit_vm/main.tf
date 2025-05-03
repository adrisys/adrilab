terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

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
  tags    = join(",", var.tags) # Convert list to comma-separated string

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
  sshkeys   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5kvBKOfHoTWcE1w/fLVpjrAP/iPn9hMrQKpq49eacp26NZeK0DNyCRMn7glBNWtEs8wBuqRaYkAacU6OTh/CMZTBpFJHejlOPkWt2IwWnq6UI2uKsd6PLzFUo12BJXlJWCxg+dohUO46SX5mhrv+SUdgJwzTfHsXvCbJXhZJSUZflUd1R5BUpm2ospw3Kpf8Rvzg4KxaI8RfyqvgcPZIxMH3F1M39jygJvfigdBzhRe9oJ0y2FQ/yzpfkab7UetoV/2KHbr9By1Evd6xLxFk/3rCuuOqdxcf1EnHKErlt3H+SZrOdns3FWhfD4iSgKQaMW4QvEqRmF8QWssguD90T7AgD/YJ8yvwSsqaX4jFVUF3RbOh1vWYkjv3iDfZUwPEuUVBm0sEXTYaVMfQmjLBprxFEvOrux28D9o5lJW3p1bPvaMsfe55OBXlVyzk5sq/Ry4Bi6Aq6iEBJbf3/13l0Un4Kv8hQB1i/S5vb4FNWk8/BAzvJ7N97VvwotRmYkzCPiH0NkZCjWAItHq2ykVkVyMSctBojrQSMVKjPPEgTING7UXFeFxMPKwwq38BrY1qgHIB4BID/uZTDVc00t7Hn+puo6ytbn+K5aYYWVzeyoYIAV7SPbiy7FcEO7hzEbUZrAje6WKyFRLLrbDGanVnlu524fGCL+ZgC7DmdTzQbPw== test@adrilab.com"
  serial {
    id   = 0
    type = "socket"
  }

  ciuser     = var.ciuser
  cipassword = var.cipassword
}
