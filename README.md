# 🧪 AdriLab — Homelab Configuration Repository

Welcome to **AdriLab**, my personal homelab setup, designed for experimentation, learning, and self-hosting. This repository contains the configuration files, manifests, scripts, and documentation that power my infrastructure — built with **Proxmox**, **Kubernetes**, **VLAN segmentation**, and **Ubiquiti networking gear**.

This repository manages your homelab infrastructure using layered Infrastructure as Code. It is designed to support multiple environments (e.g., prod and test), with automation layered on top of a manually prepared hardware and network foundation.

## Repository Structure

Each folder represents a logical layer in the deployment stack:

### `01_terraform/`

## Terraform

Provision Proxmox VMs, networks, and cloud-init using Terraform.

- Use `main.tf` to define your infrastructure.
- Separate vars and environment overrides as needed.

### `02_ansible/`

## Ansible

Configure base OS, install packages, or bootstrap tools like K3s.

- Use inventory files per environment (e.g. prod/test).
- Store reusable roles in `roles/`.

### `03_k8s/`

## Kubernetes Configuration

Apply GitOps-style overlays using Kustomize.

- `base/` contains common resources (apps, namespaces).
- `overlays/prod/` and `overlays/test/` are environment-specific.

### `04_manual_ops/`

## Manual Operations

Track setup steps and experiments you did manually.

- Used as a scratchpad before converting to IaC.
- Include `*_bootstrap.md`, secrets, recovery steps, etc.

### `docs/`

## Documentation

Architecture, workflows, diagrams, and decisions.

- Use `architecture.md` to describe the stack.
- Store diagrams or Markdown maps.

---

## Workflow Overview

1. Manually ensure Proxmox and networking are in place.
2. Run Terraform to provision VMs and inject cloud-init.
3. Use Ansible to configure OS or install Kubernetes (K3s).
4. Deploy Kubernetes manifests using Kustomize overlays.
5. Document any manual or post-deploy steps in `04_manual_ops/`.

Use `manual_ops/README.md` to track what you've done by hand and decide when to automate.

## 🚀 Goals

- Maintain a production-grade personal lab for continuous learning
- Test real-world DevOps, SRE, and infrastructure-as-code practices
- Host critical personal services in a secure and redundant manner

---

## 🧑‍💻 About the Author

This homelab is maintained by Adri — a DevOps engineer passionate about infrastructure, automation, and building reliable systems at home and at scale.

---

## 📬 Feedback & Contributions

This is a personal repo, but feel free to open issues or PRs if you spot something useful or broken. Sharing ideas or improvements is always welcome!

---

## 🛡️ Disclaimer

**Use at your own risk** — these configs are tailored to my environment and may require adaptation for yours. Sensitive data has been stripped or encrypted.
