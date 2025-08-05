# ==============================================================================
# LXC CONTAINER MODULE OUTPUTS
# ==============================================================================

output "lxc_ips" {
  description = "IPv4 addresses of the created LXC containers"
  value       = [for container in proxmox_lxc.container : container.network.0.ip]
}

output "lxc_names" {
  description = "Hostnames of the created LXC containers"
  value       = [for container in proxmox_lxc.container : container.hostname]
}

output "lxc_ids" {
  description = "IDs of the created LXC containers"
  value       = [for container in proxmox_lxc.container : container.id]
}