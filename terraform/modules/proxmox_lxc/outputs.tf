# output "lxc_hostnames" {
#   description = "Hostnames of the created LXC containers"
#   value       = [for lxc in proxmox_lxc.lxc-test : lxc.hostname]
# }

# output "lxc_ips" {
#   description = "IPv4 addresses of the created LXC containers"
#   value       = [for lxc in proxmox_lxc.lxc-test : lxc.network.0.ip]
# }