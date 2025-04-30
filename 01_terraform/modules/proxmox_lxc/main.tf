terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

resource "proxmox_lxc" "lxc-test" {
  count    = var.lxc_count
  hostname = "${var.lxc_hostname}-${count.index + 1}"
  features {
    nesting = true
  }
  network {
    name   = "eth0"
    bridge = var.lxc_network_bridge
    ip     = var.lxc_network_ip
    ip6    = var.lxc_network_ip6
    gw     = var.lxc_gateway
    tag    = var.lxc_network_tag
  }
  
  ostemplate = var.lxc_ostemplate
  password   = var.lxc_password
  rootfs {
    storage = var.lxc_rootfs_storage
    size    = var.lxc_disk_size
  }
  target_node  = var.target_node
  unprivileged = true

  ssh_public_keys = var.ssh_public_keys
}
