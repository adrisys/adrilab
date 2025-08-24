# ==============================================================================
# LXC CONTAINERS CONFIGURATION
# ==============================================================================

# LXC Container
module "proxmox_lxc_container" {
  source = "./modules/proxmox_lxc"

  # Container Configuration
  lxc_count      = 1
  lxc_hostname   = var.lxc_hostname
  target_node    = var.target_node
  lxc_ostemplate = var.lxc_ostemplate
  lxc_password   = var.lxc_password
  unprivileged   = var.unprivileged
  nesting        = var.nesting
  lxc_cores      = var.lxc_cores
  lxc_memory     = var.lxc_memory

  # Storage Configuration
  lxc_rootfs_storage = var.lxc_rootfs_storage
  lxc_rootfs_size    = var.lxc_rootfs_size

  # Network Configuration
  lxc_network_bridge = var.lxc_network_bridge
  lxc_network_ip     = var.lxc_network_ip
  lxc_network_ip6    = var.lxc_network_ip6
  lxc_gateway        = var.lxc_gateway
  lxc_network_tag    = var.lxc_network_tag

  # Authentication & Access
  ssh_public_keys = var.ssh_public_key
  tags            = var.tags

  # Boot Configuration
  onboot = true

  # Protection
  protection = true

}
