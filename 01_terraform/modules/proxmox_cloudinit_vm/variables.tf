variable "vm_count" {
  type        = number
  description = "Number of VMs to create"
}

variable "vm_name" {
  description = "Base name for the VMs"
  type        = string
}

variable "vm_description" {
  description = "Description for the VM"
  type        = string
}

variable "target_node" {
  description = "Proxmox node to deploy the VM"
  type        = string
  default     = "pve"
}

variable "clone_template" {
  description = "Template to clone for the VM"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 0
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
  default     = 2048
}



variable "cloudinit_storage" {
  description = "Storage for cloud-init disk"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size (e.g., 10G)"
  type        = string
  default     = 32
}

variable "disk_cache" {
  description = "Disk cache mode (e.g., writeback)"
  type        = string
  default     = "writeback"

}

variable "disk_storage" {
  description = "Storage location for the disk"
  type        = string
  default     = "local-lvm"
}

variable "disk_replicate" {
  description = "Enable disk replication"
  type        = bool
  default     = true
}

variable "network_model" {
  description = "Network model (e.g., virtio)"
  type        = string
  default     = "virtio"
}

variable "network_bridge" {
  description = "Network bridge (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "network_tag" {
  description = "VLAN tag for the network interface"
  type        = number
}

variable "ipconfig0" {
  description = "IP configuration for the VM"
  type        = string
  default     = "ip=dhcp"
}

variable "ciuser" {
  description = "Username for cloud-init"
  type        = string
  default     = "adri"
}

variable "cipassword" {
  description = "Password for cloud-init user"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "The public SSH key to inject into the VM"
  type        = string
}

variable "ip_base" {
  description = "Base IP address (first three octets)"
  type        = string
  default     = "10.0.50"
}

variable "ip_start" {
  description = "Starting value for the last octet of IP addresses"
  type        = number
  default     = 10
}

variable "ip_netmask" {
  description = "Subnet mask for IP addresses"
  type        = string
  default     = "24"
}

variable "ip_gateway" {
  description = "Gateway IP address"
  type        = string
  default     = "10.0.50.1"
}

variable "tags" {
  description = "Tags for the VM"
  type        = list(string)
  default     = []
}