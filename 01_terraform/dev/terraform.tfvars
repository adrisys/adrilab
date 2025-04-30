#vms
vm_count       = 1
vm_name        = "cloudinit-test"
vm_description = "A test VM with cloud-init configured"
target_node    = "pve"
clone_template = "ubuntu-template-24.04-LTS"

cores   = 2
sockets = 1
vcpus   = 0
memory  = 2048

cloudinit_storage = "local-lvm"
disk_size         = 32
disk_cache        = "writeback"
disk_storage      = "local-lvm"
disk_replicate    = true

network_model  = "virtio"
network_bridge = "vmbr0"
network_tag    = 50
#ipconfig0 = "ip=10.0.50.168/24,gw=10.0.50.1"
ipconfig0      = "ip=dhcp"

ciuser         = "adri"
cipassword     = "adri"
ssh_public_key = ""


#lxc
lxc_count    = 1
lxc_hostname = "terraform-new-lxc"

lxc_network_bridge = "vmbr0"

#lxc_network_ip = "10.0.50.169/24"
lxc_network_ip     = "dhcp"
lxc_gateway = "10.0.50.1"
lxc_network_ip6    = "auto"
lxc_network_tag    = 50

lxc_ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
lxc_disk_size    = "8G"
lxc_password     = "adriadri"
lxc_disk_storage = "local-lvm"

lxc_rootfs_size    = "8G"
lxc_rootfs_storage = "local-lvm"
