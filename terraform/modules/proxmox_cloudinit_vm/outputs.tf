output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.cloudinit_vm : vm.ipconfig0]
}