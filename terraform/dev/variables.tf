#vms
variable "vm_count" {}
variable "vm_name" {}
variable "vm_description" {}
variable "target_node" {}
variable "clone_template" {}
variable "cores" {}
variable "sockets" {}
variable "vcpus" {}
variable "memory" {}
variable "cloudinit_storage" {}
variable "disk_size" {}
variable "disk_cache" {}
variable "disk_storage" {}
variable "disk_replicate" {}
variable "network_model" {}
variable "network_bridge" {}
variable "network_tag" {}
variable "ipconfig0" {}
variable "ciuser" {}
variable "cipassword" {}
variable "ssh_public_key" {}

#lxc
variable "lxc_count" {}
variable "lxc_hostname" {}
variable "lxc_network_bridge" {}
variable "lxc_network_ip" {}
variable "lxc_network_ip6" {}
variable "lxc_network_tag" {}
variable "lxc_ostemplate" {}
variable "lxc_password" {}
variable "lxc_disk_storage" {}
variable "lxc_disk_size" {}
variable "lxc_rootfs_storage" {}
variable "lxc_rootfs_size" {} 
