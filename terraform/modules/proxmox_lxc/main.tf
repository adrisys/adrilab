# ==============================================================================
# PROXMOX LXC CONTAINER MODULE
# ==============================================================================

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

# LXC Container Resource
resource "proxmox_lxc" "container" {
  count        = var.lxc_count
  hostname     = var.lxc_count > 1 ? "${var.lxc_hostname}-${count.index + 1}" : var.lxc_hostname
  target_node  = var.target_node
  ostemplate   = var.lxc_ostemplate
  password     = var.lxc_password
  unprivileged = var.unprivileged

  # Resource Configuration
  cores  = var.lxc_cores
  memory = var.lxc_memory

  # Container Features
  features {
    nesting = var.nesting
  }

  # Root Filesystem Configuration
  rootfs {
    storage = var.lxc_rootfs_storage
    size    = var.lxc_rootfs_size
  }

  # Network Configuration
  network {
    name   = "eth0"
    bridge = var.lxc_network_bridge
    ip     = var.lxc_network_ip
    ip6    = var.lxc_network_ip6
    gw     = var.lxc_gateway
    tag    = var.lxc_network_tag
  }

  # SSH Access
  ssh_public_keys = var.ssh_public_keys

  # Tags
  tags = join(",", var.tags)
}
