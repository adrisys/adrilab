#!/bin/bash

# Setup script for local configuration files in GitHub Actions
# This script should be called in your workflow after checkout

set -e

echo "🔧 Setting up local configuration files for self-hosted runner..."

# Check if we're running on a self-hosted runner
if [ -z "$RUNNER_NAME" ] || [[ "$RUNNER_NAME" != *"self-hosted"* ]]; then
    echo "ℹ️ Not running on self-hosted runner, skipping local config setup"
    exit 0
fi

# Setup Terraform variables
if [ -f "/home/runner/terraform.tfvars" ]; then
    echo "✓ Copying local terraform.tfvars to terraform directory..."
    cp /home/runner/terraform.tfvars terraform/terraform.tfvars
else
    echo "⚠️ Local terraform.tfvars not found at /home/runner/terraform.tfvars"
    echo "   Make sure it's mounted as a volume in docker-compose.yml"
fi

# Check if the local hosts.yml is already mounted directly into the repo structure
if [ -f "ansible/inventory/hosts.yml" ]; then
    echo "✓ Local hosts.yml found in ansible/inventory/"
else
    echo "⚠️ Local hosts.yml not found in ansible/inventory/"
    echo "   Make sure it's mounted directly into the repository structure"
fi

# Fix SSH permissions if needed
if [ -d "/home/runner/.ssh" ]; then
    echo "✓ Setting correct SSH key permissions..."
    chmod 700 /home/runner/.ssh 2>/dev/null || true
    chmod 600 /home/runner/.ssh/* 2>/dev/null || true
fi

echo "✅ Local configuration setup complete!"
