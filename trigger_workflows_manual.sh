#!/bin/bash

# ==============================================================================
# MANUAL WORKFLOW TRIGGER (via GitHub Web Interface)
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_header "GITHUB ACTIONS MANUAL TRIGGER"

echo ""
print_status "Your GitHub runner is configured and ready!"
print_status "Local files will be used from this machine:"
echo "  📁 terraform.tfvars: /root/adrilab/terraform/terraform.tfvars"
echo "  📁 hosts.yml: /root/adrilab/ansible/inventory/hosts.yml"

echo ""
print_header "TO TRIGGER WORKFLOWS MANUALLY:"

echo ""
print_status "1. Go to your GitHub repository: https://github.com/adrisys/adrilab"
print_status "2. Navigate to Actions tab"
print_status "3. Select the workflow you want to run:"

echo ""
echo "   🏗️  TERRAFORM INFRASTRUCTURE:"
echo "      - Click on '🏗️ Terraform Infrastructure'"
echo "      - Click 'Run workflow'"
echo "      - Choose action: 'plan' or 'apply'"
echo "      - Click 'Run workflow'"

echo ""
echo "   ⚙️  ANSIBLE CONFIGURATION:"
echo "      - Click on '⚙️ Ansible Configuration'"
echo "      - Click 'Run workflow'"
echo "      - Set target_group: 'all' or specific group (k8s_cluster, cardano, etc.)"
echo "      - Set check_only: true for dry-run, false for actual deployment"
echo "      - Click 'Run workflow'"

echo ""
print_header "RUNNER STATUS"

# Check if runner container is running
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q adrxlab-github-runner; then
    print_status "✅ GitHub runner container is running"
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep adrxlab-github-runner
else
    echo -e "${RED}❌ GitHub runner container is not running${NC}"
    echo "Start it with: cd docker/github-runner && docker-compose up -d"
fi

echo ""
print_header "LOCAL FILES STATUS"

if [ -f "/root/adrilab/terraform/terraform.tfvars" ]; then
    print_status "✅ terraform.tfvars found"
    echo "   Last modified: $(stat -c %y /root/adrilab/terraform/terraform.tfvars)"
else
    echo -e "${RED}❌ terraform.tfvars not found${NC}"
fi

if [ -f "/root/adrilab/ansible/inventory/hosts.yml" ]; then
    print_status "✅ hosts.yml found"
    echo "   Last modified: $(stat -c %y /root/adrilab/ansible/inventory/hosts.yml)"
else
    echo -e "${RED}❌ hosts.yml not found${NC}"
fi

echo ""
print_header "WHAT HAPPENS WHEN YOU RUN A WORKFLOW:"

echo ""
echo "🏗️  TERRAFORM WORKFLOW:"
echo "   1. Copies your local terraform.tfvars to the workflow"
echo "   2. Runs terraform init, validate, plan/apply"
echo "   3. Uses your Proxmox and AWS credentials from GitHub Secrets"
echo "   4. Creates/modifies infrastructure based on your local config"

echo ""
echo "⚙️  ANSIBLE WORKFLOW:"
echo "   1. Copies your local hosts.yml to the workflow"
echo "   2. Validates Ansible playbook syntax"
echo "   3. Runs playbooks against the hosts in your inventory"
echo "   4. Uses SSH keys from GitHub Secrets for authentication"

echo ""
print_status "Ready to go! 🚀"

