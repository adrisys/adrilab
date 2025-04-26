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

resource "proxmox_vm_qemu" "cloudinit-test" {
    count = 1
    name = "cloudinit-test-${count.index + 1}"
    desc = "A test for using terraform and cloudinit"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve"

    # The destination resource pool for the new VM
#    pool = "pool0"

    # The template name to clone this vm from
    clone = "VM 9001"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    memory = 2048
    scsihw = "virtio-scsi-pci"

    # Setup the disk
    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    size            = 32
                    cache           = "writeback"
                    storage         = "local-lvm"
                    #storage_type    = "rbd"
                    #iothread        = true
                    #discard         = true
                    replicate       = true
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        id     = 0
        model  = "virtio"
        bridge = "vmbr0"
        tag = 50
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi0"
    # Keep in mind to use the CIDR notation for the ip.
    #ipconfig0 = "ip=192.168.10.20/24,gw=192.168.10.1"
    ipconfig0 = "ip=dhcp"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5kvBKOfHoTWcE1w/fLVpjrAP/iPn9hMrQKpq49eacp26NZeK0DNyCRMn7glBNWtEs8wBuqRaYkAacU6OTh/CMZTBpFJHejlOPkWt2IwWnq6UI2uKsd6PLzFUo12BJXlJWCxg+dohUO46SX5mhrv+SUdgJwzTfHsXvCbJXhZJSUZflUd1R5BUpm2ospw3Kpf8Rvzg4KxaI8RfyqvgcPZIxMH3F1M39jygJvfigdBzhRe9oJ0y2FQ/yzpfkab7UetoV/2KHbr9By1Evd6xLxFk/3rCuuOqdxcf1EnHKErlt3H+SZrOdns3FWhfD4iSgKQaMW4QvEqRmF8QWssguD90T7AgD/YJ8yvwSsqaX4jFVUF3RbOh1vWYkjv3iDfZUwPEuUVBm0sEXTYaVMfQmjLBprxFEvOrux28D9o5lJW3p1bPvaMsfe55OBXlVyzk5sq/Ry4Bi6Aq6iEBJbf3/13l0Un4Kv8hQB1i/S5vb4FNWk8/BAzvJ7N97VvwotRmYkzCPiH0NkZCjWAItHq2ykVkVyMSctBojrQSMVKjPPEgTING7UXFeFxMPKwwq38BrY1qgHIB4BID/uZTDVc00t7Hn+puo6ytbn+K5aYYWVzeyoYIAV7SPbiy7FcEO7hzEbUZrAje6WKyFRLLrbDGanVnlu524fGCL+ZgC7DmdTzQbPw== adrian.navarro@outlook.com
    EOF
    serial {
      id   = 0
      type = "socket"
    }
    
    ciuser = "adri"
    cipassword = "adri"

}