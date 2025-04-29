# 🛠️ Proxmox Infrastructure with Terraform

This repository manages LXC containers and VMs on a Proxmox cluster using Terraform. It supports modular deployment for development and production environments.

---

## 📁 Project Structure

terraform/
├── dev/                           # Development environment
│   ├── lxc.tf                     # LXC container definitions
│   ├── vm.tf                      # VM definitions
│   ├── provider.tf                # Provider configuration
│   ├── variables.tf               # Variable declarations
│   ├── terraform.tfvars           # Variable values for dev
│   ├── proxmox-cloudinit-template.sh  # Optional script for Cloud-Init images
│   └── .terraform/                # Terraform system files (do not edit manually)
├── modules/                       # Terraform modules
│   ├── proxmox_cloudinit_vm/      # Module for Cloud-Init-based VMs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── proxmox_lxc/               # Module for LXC container deployment
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── prod/                          # (Optional) Production environment placeholder
└── .terraform.lock.hcl            # Provider version lock file

---

## ⚙️ How It Works

- **Provider:** Uses the [Telmate Proxmox Terraform provider](https://github.com/Telmate/terraform-provider-proxmox).
- **Modules:** 
  - `proxmox_lxc`: Defines logic to create and manage LXC containers.
  - `proxmox_cloudinit_vm`: Handles Cloud-Init-enabled VM provisioning.
- **Environments:**
  - The `dev/` directory defines infrastructure for development purposes.
  - You can replicate this structure for `prod/` and others.

---

## 🚀 Getting Started

### 1. Install Dependencies

- Terraform >= 1.0
- Access to a Proxmox VE cluster
- SSH key configured (e.g., `adrilab.pub`)

### 2. Initialize Terraform

```bash
cd terraform/dev
terraform init