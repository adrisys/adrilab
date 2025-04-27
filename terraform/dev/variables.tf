variable "vm_count" {
  default = 1
}

variable "vm_name" {
  description = "Name prefix for the VMs"
}

variable "vm_description" {
  default = "A cloud-init VM created with Terraform"
}

variable "target_node" {}

variable "clone_template" {}

variable "cores" {
  default = 2
}

variable "sockets" {
  default = 1
}

variable "vcpus" {
  default = 0
}

variable "memory" {
  default = 2048
}

variable "cloudinit_storage" {
  default = "local-lvm"
}

variable "disk_size" {
  default = 32
}

variable "disk_cache" {
  default = "writeback"
}

variable "disk_storage" {
  default = "local-lvm"
}

variable "disk_replicate" {
  default = true
}

variable "network_model" {
  default = "virtio"
}

variable "network_bridge" {
  default = "vmbr0"
}

variable "network_tag" {
  default = 50
}

variable "ipconfig0" {
  default = "ip=dhcp"
}

variable "ssh_public_keys" {
  type = string
}

variable "ciuser" {
  default = "adri"
}

variable "cipassword" {
  default = "adri"
}
