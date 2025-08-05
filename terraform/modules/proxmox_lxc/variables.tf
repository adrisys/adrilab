
# ==============================================================================
# LXC CONTAINER MODULE VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# Container Configuration
# ------------------------------------------------------------------------------

variable "lxc_count" {
  description = "Number of LXC containers to create"
  type        = number
}

variable "lxc_hostname" {
  description = "Base hostname for the LXC containers"
  type        = string
  default     = "lxc-container"
}

variable "target_node" {
  description = "Proxmox node to deploy the LXC container"
  type        = string
  default     = "pve"
}

variable "lxc_ostemplate" {
  description = "Path to the OS template for the LXC container"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

variable "lxc_password" {
  description = "Root password for the LXC container"
  type        = string
  sensitive   = true
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

# ------------------------------------------------------------------------------
# Network Configuration
# ------------------------------------------------------------------------------

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

variable "lxc_gateway" {
  description = "Gateway for the LXC container"
  type        = string
  default     = "10.50.0.1"
}

variable "lxc_network_tag" {
  description = "VLAN tag for the network interface"
  type        = number
  default     = 0
}

# ------------------------------------------------------------------------------
# Resource Configuration
# ------------------------------------------------------------------------------

variable "lxc_cores" {
  description = "Number of CPU cores to allocate to the LXC container"
  type        = number
  default     = 1
}

variable "lxc_memory" {
  description = "Amount of memory in MB to allocate to the LXC container"
  type        = number
  default     = 512
}

# ------------------------------------------------------------------------------
# Storage Configuration
# ------------------------------------------------------------------------------

variable "lxc_rootfs_storage" {
  description = "Storage location for the root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "lxc_rootfs_size" {
  description = "Size of the root filesystem (e.g., '8G')"
  type        = string
  default     = "8G"
}

# ------------------------------------------------------------------------------
# Authentication & Access
# ------------------------------------------------------------------------------

variable "ssh_public_keys" {
  description = "SSH public keys to inject into the LXC container"
  type        = string
}

# ------------------------------------------------------------------------------
# Metadata
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the LXC container"
  type        = list(string)
  default     = []
}
