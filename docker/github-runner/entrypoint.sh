#!/bin/bash

set -e

# GitHub repository and runner configuration
GITHUB_OWNER=${GITHUB_OWNER:-"adrisys"}
GITHUB_REPO=${GITHUB_REPO:-"adrxlab"}
RUNNER_NAME=${RUNNER_NAME:-"self-hosted-terraform-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,terraform,proxmox,ansible"}

# GitHub token (you'll need to provide this)
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN environment variable is required"
    exit 1
fi

# Setup local configuration files if they exist
echo "Setting up local configuration files..."

# Check if local terraform.tfvars is mounted
if [ -f "/home/runner/terraform.tfvars" ]; then
    echo "✓ Found local terraform.tfvars at /home/runner/terraform.tfvars"
else
    echo "⚠ No local terraform.tfvars found. Make sure to mount it as a volume."
fi

# Check if local hosts.yml is mounted
if [ -f "/home/runner/hosts.yml" ]; then
    echo "✓ Found local hosts.yml at /home/runner/hosts.yml"
else
    echo "⚠ No local hosts.yml found. Make sure to mount it as a volume."
fi

# Check SSH keys
if [ -d "/home/runner/.ssh" ]; then
    echo "✓ Found SSH keys directory"
    # Fix permissions for SSH keys
    chmod 700 /home/runner/.ssh || true
    chmod 600 /home/runner/.ssh/* 2>/dev/null || true
    chown -R runner:runner /home/runner/.ssh 2>/dev/null || true
else
    echo "⚠ No SSH keys found. Make sure to mount ~/.ssh as a volume for Ansible."
fi

# Get runner registration token
echo "Getting runner registration token..."
RUNNER_TOKEN=$(curl -s -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners/registration-token" | jq -r .token)

if [ "$RUNNER_TOKEN" == "null" ] || [ -z "$RUNNER_TOKEN" ]; then
    echo "ERROR: Failed to get runner registration token"
    exit 1
fi

# Download and setup GitHub Actions runner
echo "Downloading GitHub Actions runner..."
RUNNER_VERSION="2.321.0"
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
echo "Installing GitHub Actions runner dependencies..."
if [ -f "./bin/installdependencies.sh" ]; then
    sudo ./bin/installdependencies.sh
fi

# Configure the runner
echo "Configuring runner..."
./config.sh \
    --url "https://github.com/$GITHUB_OWNER/$GITHUB_REPO" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "_work" \
    --replace \
    --unattended

# Cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "$RUNNER_TOKEN" || true
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Start the runner
echo "Starting runner..."
./run.sh
