#!/bin/bash

# GitHub Runner Local Setup Script
# This script helps set up local configuration files for the GitHub runner

set -e

echo "🚀 GitHub Runner Local Configuration Setup"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Please run this script from the docker/github-runner directory"
    exit 1
fi

# Go to the repo root
cd ../../

echo "📁 Checking for required configuration files..."

# Check terraform.tfvars
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "⚠️  terraform/terraform.tfvars not found"
    if [ -f "terraform/terraform.tfvars.example" ]; then
        echo "📝 Creating terraform/terraform.tfvars from example..."
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        echo "✅ Created terraform/terraform.tfvars - please edit with your actual values"
    else
        echo "❌ terraform/terraform.tfvars.example not found either!"
        exit 1
    fi
else
    echo "✅ terraform/terraform.tfvars found"
fi

# Check ansible hosts.yml
if [ ! -f "ansible/inventory/hosts.yml" ]; then
    echo "⚠️  ansible/inventory/hosts.yml not found"
    if [ -f "ansible/inventory/hosts.yml.example" ]; then
        echo "📝 Creating ansible/inventory/hosts.yml from example..."
        cp ansible/inventory/hosts.yml.example ansible/inventory/hosts.yml
        echo "✅ Created ansible/inventory/hosts.yml - please edit with your actual hosts"
    else
        echo "❌ ansible/inventory/hosts.yml.example not found either!"
        exit 1
    fi
else
    echo "✅ ansible/inventory/hosts.yml found"
fi

# Check SSH keys
if [ -d ~/.ssh ]; then
    echo "✅ SSH directory (~/.ssh) found"
    if ls ~/.ssh/id_* >/dev/null 2>&1; then
        echo "✅ SSH keys found in ~/.ssh/"
    else
        echo "⚠️  No SSH keys found in ~/.ssh/ - you may need to generate or copy them"
    fi
else
    echo "⚠️  ~/.ssh directory not found - you may need to set up SSH keys"
fi

# Check .env file
cd docker/github-runner
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found"
    echo "📝 Please create a .env file with:"
    echo "   GITHUB_TOKEN=your_github_personal_access_token"
    echo ""
    echo "You can also set it as an environment variable:"
    echo "   export GITHUB_TOKEN=your_token"
else
    echo "✅ .env file found"
fi

echo ""
echo "🔧 Setup Summary:"
echo "================"
echo "1. ✓ Configuration files checked/created"
echo "2. ✓ SSH keys directory verified"
echo "3. ⚠ Make sure to:"
echo "   - Edit terraform/terraform.tfvars with your actual values"
echo "   - Edit ansible/inventory/hosts.yml with your actual hosts"
echo "   - Set GITHUB_TOKEN in .env file or environment"
echo ""
echo "🚀 Ready to start the runner:"
echo "   docker-compose up -d"
echo ""
echo "📖 For more details, see LOCAL_CONFIG.md"
