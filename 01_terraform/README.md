# AdrILab Terraform Project

This repository contains Terraform configurations for managing infrastructure components in the **AdrILab** environment, with a focus on the **Proxmox** virtualization platform.


## 🧩 Modules

### 🔹 Proxmox Cloud-Init VM Module

This module creates and manages **Proxmox virtual machines** using **cloud-init** for initialization.

#### ✅ Features

- Supports multiple VM creation with `count`
- Configurable hardware resources (CPU, memory)
- Cloud-init integration for initial configuration
- Network configuration with VLAN support
- SSH key provisioning

#### 📤 Outputs

- `vm_ips`: List of IP addresses assigned to created VMs

---

### 🔹 Proxmox LXC Module

This module creates and manages **Proxmox Linux Containers (LXC)**.

#### ✅ Features

- Supports multiple container creation with `count`
- Configurable resources
- Network configuration with VLAN support
- Storage configuration

#### 📤 Outputs

- `lxc_ips`: List of IP addresses assigned to created LXC containers

---

## 🚀 Usage

### 🔧 Prerequisites

- Install **Terraform** (v1.0.0+)
- Configure **Proxmox provider authentication**

---

### 📦 Deployment

Navigate to the development environment directory:

```bash
cd path/to/dev
```

#### Initialize Terraform

```bash
terraform init
```

#### Review the plan

```bash
terraform plan
```

#### Apply the configuration

```bash
terraform apply
```

---

## ⚙️ Configuration

Modify `terraform.tfvars` to customize the deployment:

- VM Configuration
- LXC Configuration

---

## 📝 Notes

- When changing the **network configuration** of existing LXC containers (e.g., from **DHCP to static IP**), you may need to **destroy and recreate the container** due to **Proxmox API limitations**.

## 📄 License

This project is licensed under the **MIT License**.
