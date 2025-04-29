# resource "proxmox_lxc" "lxc-test" {
#     features {
#         nesting = true
#     }
#     hostname = "terraform-new-container"
#     network {
#         name = "eth0"
#         bridge = "vmbr0"
#         ip = "dhcp"
#         ip6 = "dhcp"
#         tag = var.network_tag
#     }
#     ostemplate = var.ostemplate
#     password = "rootroot"
#     rootfs {
#     storage = "local-lvm"
#     size    = "8G"
#     }
#     target_node = "pve"
#     unprivileged = true

#     ssh_public_keys = file("${path.module}/adrilab.pub")
# }