output "vm_ids" {
  value = [for vm in proxmox_vm_qemu.cloudinit_vm : vm.id]
}