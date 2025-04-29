# output "vm_ids" {
#   value = [for vm in proxmox_vm_qemu.cloudinit_vm : vm.id]
# }

# output "vm_ips" {
#   description = "IP addresses of the created VMs"
#   value       = [for vm in proxmox_vm_qemu.cloudinit_vm : vm.network.0.ip]
# }