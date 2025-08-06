#!/bin/bash

# ==============================================================================
# GITHUB RUNNER WORKFLOW TRIGGER SCRIPT
# ==============================================================================
# 
# This script helps trigger GitHub Actions workflows on your local runner
# that will apply your local hosts.yml and terraform.tfvars configurations.
#
# Prerequisites:
# - GitHub CLI (gh) installed and authenticated
# - GitHub runner container running with local files mounted
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

# Check if gh CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed or not in PATH"
        print_status "Install it with: apt install gh"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated"
        print_status "Run: gh auth login"
        exit 1
    fi
}

# Check if runner is running
check_runner() {
    if ! docker ps | grep -q adrxlab-github-runner; then
        print_error "GitHub runner container is not running"
        print_status "Start it with: cd docker/github-runner && docker-compose up -d"
        exit 1
    fi
    print_status "GitHub runner is running ✅"
}

# Function to trigger Terraform workflow
run_terraform() {
    local action=${1:-plan}
    print_header "TERRAFORM WORKFLOW - ${action^^}"
    
    print_status "Triggering Terraform workflow with action: $action"
    gh workflow run terraform.yml -f action="$action"
    
    print_status "Workflow triggered! You can monitor it with:"
    print_status "  gh run list --workflow=terraform.yml"
    print_status "  gh run watch"
}

# Function to trigger Ansible workflow
run_ansible() {
    local target_group=${1:-all}
    local check_only=${2:-false}
    print_header "ANSIBLE WORKFLOW"
    
    print_status "Triggering Ansible workflow with target: $target_group, check-only: $check_only"
    gh workflow run ansible.yml -f target_group="$target_group" -f check_only="$check_only"
    
    print_status "Workflow triggered! You can monitor it with:"
    print_status "  gh run list --workflow=ansible.yml"
    print_status "  gh run watch"
}

# Function to show help
show_help() {
    cat << 'HELP'
GitHub Runner Workflow Trigger Script

Usage:
  ./run_workflows.sh [COMMAND] [OPTIONS]

Commands:
  terraform [plan|apply]     - Run Terraform workflow
                              plan  = Generate execution plan (default)
                              apply = Apply infrastructure changes
  
  ansible [GROUP] [CHECK]    - Run Ansible workflow
                              GROUP = Target host group (default: all)
                              CHECK = true for check mode (default: false)
  
  status                     - Show runner and workflow status
  help                       - Show this help message

Examples:
  ./run_workflows.sh terraform plan     # Plan infrastructure changes
  ./run_workflows.sh terraform apply    # Apply infrastructure changes
  ./run_workflows.sh ansible all false  # Deploy to all hosts
  ./run_workflows.sh ansible k8s_cluster true  # Check k8s cluster hosts
  ./run_workflows.sh status             # Show status

Your local files will be used:
  - /root/adrilab/terraform/terraform.tfvars
  - /root/adrilab/ansible/inventory/hosts.yml

HELP
}

# Function to show status
show_status() {
    print_header "GITHUB RUNNER STATUS"
    
    # Check runner container
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep adrxlab-github-runner; then
        print_status "Runner container is running ✅"
    else
        print_warning "Runner container is not running ❌"
    fi
    
    # Check recent workflow runs
    print_header "RECENT WORKFLOW RUNS"
    gh run list --limit 5 2>/dev/null || print_warning "Could not fetch workflow runs (check gh auth)"
    
    print_header "LOCAL FILES STATUS"
    if [ -f "/root/adrilab/terraform/terraform.tfvars" ]; then
        print_status "terraform.tfvars found ✅"
    else
        print_warning "terraform.tfvars not found ❌"
    fi
    
    if [ -f "/root/adrilab/ansible/inventory/hosts.yml" ]; then
        print_status "hosts.yml found ✅"
    else
        print_warning "hosts.yml not found ❌"
    fi
}

# Main logic
main() {
    case "${1:-help}" in
        terraform)
            check_gh_cli
            check_runner
            run_terraform "${2:-plan}"
            ;;
        ansible)
            check_gh_cli
            check_runner
            run_ansible "${2:-all}" "${3:-false}"
            ;;
        status)
            check_gh_cli
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
