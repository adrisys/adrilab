# ==============================================================================
# INFRASTRUCTURE VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# Proxmox Configuration
# ------------------------------------------------------------------------------

variable "target_node" {
  description = "Proxmox node where VMs will be deployed"
  type        = string
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://dummy.example.com:8006"
}

variable "pm_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  default     = "dummy@dummy!dummy"
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  default     = "dummy-secret"
  sensitive   = true
}

# ------------------------------------------------------------------------------
# VM Template Configuration
# ------------------------------------------------------------------------------

variable "clone_template" {
  description = "Default VM template for cloning"
  type        = string
}

variable "clone_template_debian" {
  description = "Debian-specific VM template for cloning"
  type        = string
}

# ------------------------------------------------------------------------------
# VM Resource Allocation
# ------------------------------------------------------------------------------

variable "cores" {
  description = "Number of CPU cores per VM"
  type        = number
}

variable "sockets" {
  description = "Number of CPU sockets per VM"
  type        = number
}

variable "vcpus" {
  description = "Number of virtual CPUs per VM"
  type        = number
}

variable "memory" {
  description = "Memory allocation per VM in MB"
  type        = number
}

# ------------------------------------------------------------------------------
# Storage Configuration
# ------------------------------------------------------------------------------

variable "cloudinit_storage" {
  description = "Storage location for cloud-init disks"
  type        = string
}

variable "disk_size" {
  description = "Primary disk size for VMs"
  type        = string
}

variable "disk_size_kubespray" {
  description = "Primary disk size for VMs"
  type        = string
}

variable "disk_cache" {
  description = "Disk cache mode (writeback, writethrough, etc.)"
  type        = string
}

variable "disk_storage" {
  description = "Storage location for VM disks"
  type        = string
}

variable "disk_replicate" {
  description = "Enable disk replication"
  type        = bool
}

# ------------------------------------------------------------------------------
# Network Configuration
# ------------------------------------------------------------------------------

variable "network_model" {
  description = "Network interface model (virtio, e1000, etc.)"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to connect VMs to"
  type        = string
}

variable "network_tag" {
  description = "VLAN tag for VM network interfaces"
  type        = number
}

# ------------------------------------------------------------------------------
# IP Configuration
# ------------------------------------------------------------------------------

variable "ip_base" {
  description = "Base IP address for the network (e.g., '10.0.50')"
  type        = string
}

variable "ip_netmask" {
  description = "Network netmask (e.g., '24')"
  type        = string
}

variable "ip_gateway" {
  description = "Network gateway IP address"
  type        = string
}

variable "control_plane_ip_start" {
  description = "Starting IP for control plane VMs (last octet)"
  type        = number
}

variable "worker_ip_start" {
  description = "Starting IP for worker node VMs (last octet)"
  type        = number
}

# Kubespray-specific IP Configuration

variable "control_plane_ip_start_kubespray" {
  description = "Starting IP for kubespray control plane VMs (last octet)"
  type        = number
}

variable "worker_ip_start_kubespray" {
  description = "Starting IP for kubespray worker node VMs (last octet)"
  type        = number
}

# ------------------------------------------------------------------------------
# Authentication & Access
# ------------------------------------------------------------------------------

variable "ciuser" {
  description = "Default username for cloud-init user creation"
  type        = string
}

variable "cipassword" {
  description = "Default password for cloud-init user"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

# ------------------------------------------------------------------------------
# Metadata
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = list(string)
}

#lxc
# variable "lxc_count" {}
# variable "lxc_hostname" {}
# variable "lxc_network_bridge" {}
# variable "lxc_network_ip" {}
# variable "lxc_network_ip6" {}
# variable "lxc_gateway" {}
# variable "lxc_network_tag" {}
# variable "lxc_ostemplate" {}
# variable "lxc_password" {}
# variable "lxc_disk_storage" {}
# variable "lxc_disk_size" {}
# variable "lxc_rootfs_storage" {}
# variable "lxc_rootfs_size" {}
