# 🧪 AdriLab — Homelab Configuration Repository

[![🏗️ Terraform Infrastructure](https://github.com/adrisys/adrilab/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/adrisys/adrilab/actions/workflows/terraform.yml)
[![⚙️ Ansible Configuration](https://github.com/adrisys/adrilab/actions/workflows/ansible.yml/badge.svg)](https://github.com/adrisys/adrilab/actions/workflows/ansible.yml)

Welcome to **AdriLab**, my **production homelab** infrastructure repository. This is the actual configuration I use daily to manage my homelab environment, which I've decided to open-source and share with the community to demonstrate real-world best practices for homelab infrastructure management.

This repository showcases practical Infrastructure as Code patterns using **Proxmox**, **Kubernetes** (via Kubespray), **Terraform**, **Ansible**, and containerized applications. All sensitive information has been carefully removed or templated to protect privacy while maintaining the educational value of the configurations.

**Why I'm sharing this:** The homelab community thrives on sharing knowledge and real implementations. Rather than creating yet another tutorial, I'm sharing my actual working infrastructure so others can learn from real-world patterns, configurations, and the evolution of a production homelab.

## Repository Structure

This repository follows a layered approach to infrastructure management. Each directory represents a different aspect of the homelab:

### `terraform/`

**Infrastructure Provisioning** - Terraform configurations for Proxmox VM management.

- **Modules**: Reusable Proxmox VM and LXC container modules
- **Cloud-init Integration**: Automated VM initialization and SSH key deployment
- **Multiple VM Types**: Supports both Kubeadm and Kubespray K8s deployments
- **VLAN Support**: Network segmentation through Proxmox bridge configuration

### `ansible/`

**Configuration Management** - Ansible playbooks for OS-level configuration.

- **Inventory Management**: Host definitions and group variables
- **Common Role**: Base system configuration and package management
- **Modular Design**: Reusable roles for different services and configurations

### `kubernetes/`

**Container Orchestration** - Kubernetes cluster deployment using Kubespray.

- **Kubespray v2.28.0**: Production-grade Kubernetes deployment
- **Calico CNI**: Network plugin for pod networking
- **Multi-node Setup**: 1 control plane + 2 worker nodes
- **Stacked etcd**: Simplified topology for homelab use

### `python/`

**Custom Applications** - Flask-based monitoring and utility applications.

- **Health Monitoring**: Simple web app for infrastructure health checks
- **Containerized**: Docker-ready applications for K8s deployment
- **Template-based**: HTML templates for web interfaces

### `docker/`

**Container Resources** - Docker configurations and supporting services.

- **GitHub Runners**: Self-hosted CI/CD runners for automated deployments
- **Container Images**: Custom images for homelab services

### `manual_ops/`

**Operational Scripts** - Scripts and procedures for manual operations.

- **VM Templates**: Proxmox cloud-init template creation scripts
- **Bootstrap Procedures**: Initial setup and recovery operations
- **Documentation**: Manual steps before automation


---

## Technology Stack

### Core Infrastructure

- **Hypervisor**: Proxmox VE for VM and container management
- **Networking**: VLAN segmentation with Ubiquiti networking gear
- **Storage**: ZFS pools with redundancy and snapshots

### Automation & IaC

- **Terraform**: Infrastructure provisioning and VM lifecycle management
- **Ansible**: Configuration management and application deployment
- **Kubespray**: Production-grade Kubernetes cluster deployment

### Container Platform

- **Kubernetes**: Container orchestration with Calico CNI
- **Docker**: Application containerization and image management
- **Custom Apps**: Python Flask applications for monitoring and utilities

---

## Deployment Workflow

My typical infrastructure deployment follows this pattern:

1. **Hardware Foundation**: Proxmox cluster with proper networking (manual setup)
2. **VM Provisioning**: Terraform creates VMs with cloud-init configuration
3. **OS Configuration**: Ansible handles base OS setup and application installation
4. **Kubernetes Deployment**: Kubespray deploys and configures the K8s cluster
5. **Application Deployment**: Custom applications deployed via Docker/K8s
6. **Documentation**: Manual steps and learnings recorded in `manual_ops/`

## Security & Privacy

🔒 **Privacy First**: All sensitive information has been removed or templated:

- IP addresses are either examples or use RFC 1918 private ranges
- SSH keys, passwords, and tokens are templated or removed
- Personal identifiers have been sanitized
- Configuration examples use placeholder values

The goal is to share the infrastructure patterns and automation while protecting operational security.

---

## 🚀 Goals & Philosophy

- **Real-world Learning**: This homelab serves as my production environment for testing enterprise patterns at home scale
- **Community Sharing**: Open-sourcing actual working configurations to help others learn from real implementations
- **Best Practices**: Demonstrating Infrastructure as Code, GitOps, and operational excellence in a homelab context
- **Privacy & Security**: Showing how to build secure infrastructure while sharing knowledge responsibly

---

## � Community & Contributions

**Why I'm sharing this:** The homelab community has taught me so much through shared configurations and experiences. This is my way of giving back with real, working infrastructure code rather than theoretical examples.

**Contributions Welcome**: While this is my personal infrastructure, I welcome:

- Issues pointing out improvements or problems
- Pull requests with better practices or fixes
- Discussions about alternative approaches
- Questions about specific implementations

**Learning Together**: If you're building your own homelab, feel free to:

- Use these configurations as inspiration
- Ask questions about specific design decisions
- Share your own improvements or variations

---

## ⚠️ Important Notes

**Privacy & Security**:

- All sensitive data has been removed or templated
- IP addresses use private ranges or examples
- SSH keys, passwords, and personal info are sanitized
- This is meant for learning, adapt to your environment

**Use Responsibly**:

- These configurations are specific to my environment
- Test thoroughly in your own setup before deploying
- Understand each component before implementing
- Security configurations may need adjustment for your use case

---

## � What Makes This Different

Unlike many homelab tutorials that show simplified examples, this repository contains:

- **Production configurations** I actually use daily
- **Real-world complexity** with proper error handling and edge cases
- **Operational experience** embedded in scripts and documentation
- **Evolution over time** showing how infrastructure grows and changes

The goal is to bridge the gap between "hello world" tutorials and enterprise infrastructure by sharing a real, working homelab that handles actual workloads.
