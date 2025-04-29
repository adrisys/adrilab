terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

resource "proxmox_lxc" "lxc-test" {
  count = var.lxc_count
  hostname  = "${var.lxc_hostname}-${count.index + 1}"
    features {
        nesting = true
    }
    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = var.lxc_network_ip
        ip6 = var.lxc_network_ip6
        tag = var.lxc_network_tag
    }
    ostemplate = var.lxc_ostemplate
    password = var.lxc_password
    rootfs {
    storage = "local-lvm"
    size    = var.lxc_disk_size
    }
    target_node = "pve"
    unprivileged = true

    ssh_public_keys   = var.ssh_public_keys
}
