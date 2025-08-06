#!/bin/bash

# Setup script to copy local configuration files into the repository
# This should be run from GitHub Actions workflows after checkout

set -e

echo "🔧 Setting up local configuration files for runner..."

# Copy terraform.tfvars if it exists
if [ -f "/home/runner/local-config/terraform.tfvars" ]; then
    echo "✅ Copying terraform.tfvars..."
    cp /home/runner/local-config/terraform.tfvars terraform/terraform.tfvars
    echo "   → terraform/terraform.tfvars is now available"
else
    echo "⚠️  terraform.tfvars not found at /home/runner/local-config/terraform.tfvars"
fi

# Copy ansible hosts.yml if it exists
if [ -f "/home/runner/local-config/hosts.yml" ]; then
    echo "✅ Copying ansible hosts.yml..."
    mkdir -p ansible/inventory
    cp /home/runner/local-config/hosts.yml ansible/inventory/hosts.yml
    echo "   → ansible/inventory/hosts.yml is now available"
else
    echo "⚠️  hosts.yml not found at /home/runner/local-config/hosts.yml"
fi

# Verify files are accessible
echo ""
echo "🔍 Verification:"
if [ -f "terraform/terraform.tfvars" ]; then
    echo "✅ terraform/terraform.tfvars - OK"
else
    echo "❌ terraform/terraform.tfvars - MISSING"
fi

if [ -f "ansible/inventory/hosts.yml" ]; then
    echo "✅ ansible/inventory/hosts.yml - OK"
else
    echo "❌ ansible/inventory/hosts.yml - MISSING"
fi

echo "🎉 Local configuration setup complete!"
