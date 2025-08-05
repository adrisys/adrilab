# Adrxlab Terraform

This repository contains Terraform configurations for managing infrastructure components in the **Adrxlab** environment.

## 🧩 Modules

### 🔹 Proxmox Cloud-Init VM Module (`./modules/proxmox_cloudinit_vm`)

This module creates and manages **Proxmox virtual machines** using **cloud-init** for initialization.

#### ✅ Features

- Supports multiple VM creation with `count`
- Configurable hardware resources (CPU, memory, storage)
- Cloud-init integration for initial configuration
- Network configuration with VLAN support
- SSH key provisioning
- Static IP address configuration
- Custom cloud-init file support

---

### 🔹 Proxmox LXC Module (`./modules/proxmox_lxc`)

This module creates and manages **Proxmox Linux Containers (LXC)**.

> **Note**: Currently not in use - LXC variables are commented out in the main configuration.

#### ✅ LXC Features

- Supports multiple container creation with `count`
- Configurable resources (CPU, memory, storage)
- Network configuration with VLAN support
- Storage configuration
- Container nesting support

---

## 🚀 Usage

### 🔧 Prerequisites

- Install **Terraform** (v1.0.0+)
- Configure **Proxmox provider authentication**
- Access to your **Proxmox server**

---

### ⚙️ Environment Setup

1. **Configure environment variables** by sourcing the `.env` file:

   ```bash
   source .env
   ```

   The `.env` file should contain your Proxmox API credentials and SSH public key. See `.env.example` for required variables.

2. **Review configuration** in `terraform.tfvars`:

   - VM templates and resource allocation
   - Network configuration
   - Target node settings

---

### 📦 Deployment

#### Initialize Terraform

```bash
terraform init
```

#### Review the plan

```bash
source .env && terraform plan
```

#### Apply the configuration

```bash
source .env && terraform apply
```

---

## 🏛️ Architecture

### Backend Configuration

- **Remote State**: S3 backend for state management
- **State Encryption**: Enabled
- **State Key**: `terraform/terraform.tfstate`

### Network Configuration

- **Network**: Configurable subnet
- **VLAN**: Configurable VLAN tagging
- **Gateway**: Network gateway as configured
- **IP Assignment**: Static IP configuration

---

## ⚙️ Configuration Files

- `k8s-kubeadm.tf`: Main Kubernetes cluster configuration
- `terraform.tfvars`: Variable values for VM configuration
- `variables.tf`: Variable definitions
- `provider.tf`: Provider and backend configuration
- `.env`: Environment variables (not committed to git)

---

## 📝 Notes

- **Environment Variables**: Always source `.env` before running Terraform commands
- **Templates**: Ensure VM templates exist in Proxmox before deployment
- **Network**: VMs are configured with VLAN support and static IP addresses
- **State Management**: Uses S3 backend for team collaboration
- **LXC Support**: Available but currently disabled in configuration

## 📄 License

This project is licensed under the **MIT License**.
