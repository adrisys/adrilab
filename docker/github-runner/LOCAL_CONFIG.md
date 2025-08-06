# Local Configuration Setup for GitHub Runner

This guide explains how to set up your GitHub runner to work with local configuration files without committing sensitive data to git.

## Overview

The runner is configured to mount local configuration files from your host system, allowing you to keep sensitive data (like IP addresses, credentials, and infrastructure details) separate from your git repository.

## Required Local Files

### 1. Terraform Variables (`terraform/terraform.tfvars`)

This file contains your actual infrastructure configuration:

```bash
# Copy the example and customize
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your actual:
- Proxmox node names
- Network configuration (IPs, gateways, VLANs)
- Storage settings
- VM specifications

### 2. Ansible Inventory (`ansible/inventory/hosts.yml`)

This file contains your actual host inventory:

```bash
# Make sure you have the real hosts.yml (not the example)
# It should contain your actual IP addresses and hostnames
```

### 3. SSH Keys

Ensure your SSH keys are available at `~/.ssh/` for Ansible connections:
- `~/.ssh/id_adrilab` (or your specific key)
- `~/.ssh/id_adrilab.pub`

## Docker Compose Configuration

The updated `docker-compose.yml` now mounts these local files to a safe location:

```yaml
volumes:
  # Runner workspace
  - ./runner-data:/home/runner/_work:rw
  # Local configuration files (mounted to safe location)
  - /Users/adri/repos/adrilab/terraform/terraform.tfvars:/home/runner/local-config/terraform.tfvars:ro
  - /Users/adri/repos/adrilab/ansible/inventory/hosts.yml:/home/runner/local-config/hosts.yml:ro
  # SSH keys for Ansible
  - ~/.ssh:/home/runner/.ssh:ro
```

## Using in GitHub Actions Workflows

Your workflows need to copy the mounted files into the repository structure. Use the provided setup script:

### Setup Script

Each workflow should start with:

```yaml
steps:
  - name: Checkout repository
    uses: actions/checkout@v4
    
  - name: Setup local configuration files
    run: /home/runner/setup-runner-files.sh
```

This script copies:
- `/home/runner/local-config/terraform.tfvars` → `terraform/terraform.tfvars`  
- `/home/runner/local-config/hosts.yml` → `ansible/inventory/hosts.yml`

### Terraform Workflow

```yaml
name: Terraform Deploy
on: [push]
jobs:
  terraform:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform with local config
        run: |
          cd terraform
          # Copy the local terraform.tfvars that was mounted
          cp /home/runner/terraform.tfvars .
          terraform init
          terraform plan
          
      - name: Apply Terraform (if needed)
        if: github.ref == 'refs/heads/main'
        run: |
          cd terraform
          terraform apply -auto-approve
```

### Ansible Workflow

```yaml
name: Ansible Deploy
on: [push]
jobs:
  ansible:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Ansible with local inventory
        run: |
          cd ansible
          # Use the mounted hosts.yml
          ansible-playbook -i /home/runner/hosts.yml playbooks/site.yml
          
      - name: Check SSH connectivity
        run: |
          # SSH keys are mounted, so this should work
          ansible all -i /home/runner/hosts.yml -m ping
```

## Security Benefits

1. **No secrets in git**: Your actual IPs, hostnames, and network configs stay local
2. **Environment isolation**: Each workflow run gets access to current config
3. **SSH key management**: Keys are mounted read-only from your host
4. **Gitignore protection**: Sensitive files are automatically excluded

## Verification

After starting the runner, you can verify the setup:

```bash
# Check if files are properly mounted
docker exec -it adrxlab-github-runner ls -la /home/runner/

# Should show:
# terraform.tfvars
# hosts.yml
# .ssh/

# Check SSH key permissions
docker exec -it adrxlab-github-runner ls -la /home/runner/.ssh/
```

## Running the Runner

```bash
# Start the runner (from docker/github-runner directory)
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop when needed
docker-compose down
```

## Troubleshooting

### File not found errors
- Ensure the source files exist on your host system
- Check that paths in docker-compose.yml match your actual file locations

### Permission errors
- SSH keys must have correct permissions (600 for private keys)
- The entrypoint script automatically fixes SSH permissions

### Ansible connection issues
- Verify your SSH keys are in the correct location (`~/.ssh/`)
- Check that `hosts.yml` contains the correct IP addresses
- Test SSH connectivity manually first

## Alternative: Environment Variables

If you prefer, you can also pass sensitive values via environment variables:

```yaml
environment:
  - GITHUB_TOKEN=${GITHUB_TOKEN}
  - TF_VAR_proxmox_password=${PROXMOX_PASSWORD}
  - TF_VAR_lxc_password=${LXC_PASSWORD}
```

But the file mounting approach is cleaner for complex configurations.
