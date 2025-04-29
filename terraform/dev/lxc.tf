module "my_lxc_containers" {
  source = "../modules/proxmox_lxc"

  lxc_count          = var.lxc_count
  lxc_hostname       = var.lxc_hostname
  lxc_network_bridge = var.lxc_network_bridge
  lxc_network_ip     = var.lxc_network_ip
  lxc_network_ip6    = var.lxc_network_ip6
  lxc_network_tag    = var.lxc_network_tag
  lxc_ostemplate     = var.lxc_ostemplate
  lxc_password       = var.lxc_password
  lxc_rootfs_storage = var.lxc_rootfs_storage
  lxc_rootfs_size    = var.lxc_rootfs_size
  target_node        = var.target_node
  unprivileged       = true
  nesting            = true
  ssh_public_keys    = file("${path.module}/adrilab.pub")
}

output "lxc_ips" {
  value = module.my_lxc_containers.lxc_ips
}