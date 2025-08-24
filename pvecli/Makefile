.PHONY: help install dev test lint format clean build binary

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install:  ## Install in development mode
	uv venv .venv
	source .venv/bin/activate && uv pip install -e .

dev: install  ## Install with development dependencies
	source .venv/bin/activate && uv pip install -e ".[dev]"

test:  ## Run tests
	source .venv/bin/activate && python -m pytest tests/ -v

test-cov:  ## Run tests with coverage
	source .venv/bin/activate && python -m pytest tests/ --cov=pvecli --cov-report=html

lint:  ## Run linting
	source .venv/bin/activate && flake8 pvecli/ tests/
	source .venv/bin/activate && mypy pvecli/

format:  ## Format code
	source .venv/bin/activate && black pvecli/ tests/

clean:  ## Clean build artifacts
	rm -rf build/ dist/ *.egg-info/
	rm -rf .pytest_cache/ .mypy_cache/ htmlcov/
	find . -type d -name __pycache__ -delete
	find . -type f -name "*.pyc" -delete

build:  ## Build distribution
	source .venv/bin/activate && python -m build

binary:  ## Build standalone binary
	source .venv/bin/activate && uv pip install pyinstaller
	source .venv/bin/activate && python build.py

demo:  ## Show demo commands (without actual API calls)
	@echo "=== PVE CLI Demo Commands ==="
	@echo "Set up environment:"
	@echo "  export PVE_HOST='https://proxmox.example.com:8006'"
	@echo "  export PVE_TOKEN_ID='user@realm!token'"  
	@echo "  export PVE_TOKEN_SECRET='secret'"
	@echo ""
	@echo "Basic usage:"
	@echo "  pve vms                              # List all VMs"
	@echo "  pve vms --filter 'name=*k8s*'      # Filter by name"
	@echo "  pve vms --json                      # JSON output"
	@echo ""
	@echo "VM control:"
	@echo "  pve start --vmid 101 --wait         # Start and wait"
	@echo "  pve shutdown --vmid 101 --wait      # Graceful shutdown"
	@echo "  pve stop --vmid 101 --yes --wait    # Force stop"
	@echo ""
	@echo "Snapshots and backups:"
	@echo "  pve snapshot create --vmid 101 --name 'pre-upgrade' --wait"
	@echo "  pve backup --vmid 101 --storage pbs --wait"
