# Ansible Playbooks

This directory contains Ansible playbooks and related files for managing infrastructure.

## Directory Structure

- **ansible.cfg**: Ansible configuration file.
- **inventory/**: Contains inventory files and variables.
  - **hosts.yml**: Main inventory file defining hosts and groups (not tracked in git for security).
  - **hosts.yml.example**: Template for creating your own hosts.yml file.
  - **group_vars/**: Directory containing group-specific variables.
    - **all.yml**: Variables that apply to all hosts.
  
- **playbooks/**: Contains the main playbooks for configuration and deployment.
  - **site.yml**: The main playbook that configures all hosts with common settings.
  - **roles/**: Contains reusable roles for different tasks.
    - **common/**: Common tasks and configurations including defaults, files, handlers, tasks, templates, and vars.

## Setup

Before running any playbooks, you need to create your inventory file:

1. Copy the example inventory file:

   ```bash
   cp inventory/hosts.yml.example inventory/hosts.yml
   ```

2. Edit `inventory/hosts.yml` with your actual:
   - Hostnames and IP addresses
   - SSH username
   - SSH private key path

The `hosts.yml` file is not tracked in git for security reasons as it contains sensitive network information.

## Usage

To run the main playbook, use the following command:

```bash
ansible-playbook playbooks/site.yml
```

The current setup includes a single playbook (`site.yml`) that applies the common role to all hosts defined in the inventory.

Ensure that you have the necessary inventory files set up in the `inventory/hosts.yml` file for the hosts you wish to target.