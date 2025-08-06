#!/bin/bash

# Terraform Workflow Helper for Local Homelab Runner
# This script sets up Terraform for local or remote state based on environment

set -e

echo "🔧 Terraform Workflow Setup"
echo "=========================="

# Check if we're using local state
if [ "${TF_USE_LOCAL_STATE:-true}" = "true" ]; then
    echo "📁 Using local Terraform state (homelab mode)"
    
    # Use the local provider configuration
    if [ -f "provider.local.tf" ]; then
        echo "   Switching to local provider configuration..."
        mv provider.tf provider.remote.tf || true
        cp provider.local.tf provider.tf
    fi
    
    # Copy local terraform.tfvars if mounted
    if [ -f "/home/runner/terraform.tfvars" ]; then
        echo "   Copying local terraform.tfvars..."
        cp /home/runner/terraform.tfvars .
    fi
    
    # Initialize without backend
    echo "   Initializing Terraform with local state..."
    terraform init
    
else
    echo "☁️  Using remote Terraform state (S3 backend)"
    
    # Use the remote provider configuration
    if [ -f "provider.remote.tf" ]; then
        echo "   Switching to remote provider configuration..."
        cp provider.remote.tf provider.tf
    fi
    
    # Check for AWS credentials
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "❌ ERROR: AWS credentials required for remote state"
        echo "   Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    
    # Initialize with S3 backend
    echo "   Initializing Terraform with S3 backend..."
    terraform init -backend-config="bucket=${TF_VAR_bucket}" -backend-config="region=${TF_VAR_region}"
fi

echo "✅ Terraform setup complete!"
