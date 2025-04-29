
variable "lxc_hostname" {
  description = "Base hostname for the LXC containers"
  type        = string
  default     = "lxc-container"
}

variable "lxc_network_bridge" {
  description = "Network bridge to attach the LXC container to"
  type        = string
  default     = "vmbr0"
}

variable "lxc_network_ip" {
  description = "IPv4 address for the LXC container (use 'dhcp' for dynamic IP)"
  type        = string
  default     = "dhcp"
}

variable "lxc_network_ip6" {
  description = "IPv6 address for the LXC container (use 'dhcp' for dynamic IP)"
  type        = string
  default     = "dhcp"
}

variable "lxc_network_tag" {
  description = "VLAN tag for the network interface"
  type        = number
  default     = 0
}

variable "lxc_ostemplate" {
  description = "Path to the OS template for the LXC container"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"

  }

variable "lxc_password" {
  description = "Root password for the LXC container"
  type        = string
}

variable "lxc_rootfs_storage" {
  description = "Storage location for the root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  description = "Size of the root filesystem (e.g., '8G')"
  type        = string
  default     = "8G"
}

variable "target_node" {
  description = "Proxmox node to deploy the LXC container"
  type        = string
  default     = "pve"
}

variable "unprivileged" {
  description = "Whether the LXC container is unprivileged"
  type        = bool
  default     = true
}

variable "nesting" {
  description = "Enable nesting for the LXC container"
  type        = bool
  default     = true
}

variable "lxc_count" {
  type        = number
  description = "Number of LXC containers to create"
}

variable "lxc_disk_size" {
  description = "Disk size (e.g., 10G)"
  type        = string
  default     = "8G"
}

variable "lxc_disk_cache" {
  description = "Disk cache mode"
  type        = string
  default     = "writeback"
}

variable "lxc_rootfs_size" {
  description = "Size of the root filesystem (e.g., '8G')"
  type        = string
  default     = "8G"
  
}

variable "ssh_public_keys" {
  description = "SSH public keys to inject into the LXC container"
  type        = string
}
