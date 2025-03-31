# 🧪 AdriLab — Homelab Configuration Repository

Welcome to **AdriLab**, my personal homelab setup, designed for experimentation, learning, and self-hosting. This repository contains the configuration files, manifests, scripts, and documentation that power my infrastructure — built with **Proxmox**, **Kubernetes**, **VLAN segmentation**, and **Ubiquiti networking gear**.

---

## 📐 Architecture Overview

- **Hypervisor**: [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
- **Container Orchestration**: Kubernetes (via K3s or kubeadm)
- **Networking**:
  - Ubiquiti UniFi stack (Dream Machine / Switches / APs)
  - VLAN-based network segmentation
  - Static DHCP & DNS via UniFi Controller
- **Storage**: Local SSD/NVMe with ZFS pools
- **Authentication**: YubiKey-based SSH + Vault for secrets
- **Monitoring**: Prometheus, Grafana, Uptime Kuma
- **Automation**: Ansible & Bash scripts for provisioning and maintenance

---

## 📁 Repository Structure

adrilab/
├── proxmox/              # Templates, cloud-init, hook scripts, etc.
├── kubernetes/           # Helm charts, manifests, and Kustomize configs
├── networking/           # VLAN setup, UniFi backups, network topology
├── ansible/              # Playbooks for provisioning and updates
├── scripts/              # Utility scripts for automation and backups
├── docs/                 # Documentation and architecture diagrams
└── README.md             # You’re here :)


---

## 🛠️ Notable Features

- **High availability** via distributed Kubernetes nodes
- **Network isolation** with fine-grained VLANs (e.g., IoT, trusted, guest)
- **Secure remote access** through Tailscale and port knocking
- **Self-hosted services**: Git, Vaultwarden, Pi-hole, Home Assistant, and more
- **Backups** with restic + rclone to encrypted offsite storage

---

## 📸 Diagrams & Topology

Diagrams are located in `/docs/` and include:

- Network topology
- Kubernetes architecture
- Rack layout
- VLAN map

---

## 🚀 Goals

- Maintain a production-grade personal lab for continuous learning
- Test real-world DevOps, SRE, and infrastructure-as-code practices
- Host critical personal services in a secure and redundant manner

---

## 🧑‍💻 About the Author

This homelab is maintained by [Adri](#) — a DevOps engineer passionate about infrastructure, automation, and building reliable systems at home and at scale.

---

## 📬 Feedback & Contributions

This is a personal repo, but feel free to open issues or PRs if you spot something useful or broken. Sharing ideas or improvements is always welcome!

---

## 🛡️ Disclaimer

**Use at your own risk** — these configs are tailored to my environment and may require adaptation for yours. Sensitive data has been stripped or encrypted.
