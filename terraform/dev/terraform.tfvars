vm_count       = 3
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
ipconfig0      = "ip=dhcp"

ciuser         = "adri"
cipassword     = "adri"
ssh_public_key = ""