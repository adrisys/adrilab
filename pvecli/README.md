# PVE CLI - Proxmox VE Command Line Interface

A fast, simple CLI tool for managing Proxmox VE virtual machines.

## Features (v0.1.0)

- **List VMs**: `pve vms` - List all VMs with filtering
- **VM Control**: `pve start/shutdown/stop` - Control VM power states  
- **Snapshots**: `pve snapshot create` - Create VM snapshots
- **Backups**: `pve backup` - Backup VMs to storage

## Quick Start

### Installation

```bash
# Using uv (recommended)
uv venv .venv
source .venv/bin/activate  # or .venv/Scripts/activate on Windows
uv pip install -e .

# Or using pip
pip install -e .
```

### Configuration

Set environment variables:

```bash
export PVE_HOST="https://proxmox.example.com:8006"
export PVE_TOKEN_ID="user@realm!token-name"
export PVE_TOKEN_SECRET="your-secret-here"
export PVE_VERIFY_SSL=false  # optional, default false
```

Or create `~/.pvecli/config.yaml`:

```yaml
host: "https://proxmox.example.com:8006"
token_id: "user@realm!token-name"
token_secret: "your-secret-here"
verify_ssl: false

profiles:
  production:
    host: "https://pve-prod.example.com:8006"
    token_id: "prod@pve!cli"
    token_secret: "prod-secret"
  lab:
    host: "https://pve-lab.example.com:8006"
    token_id: "lab@pve!cli"  
    token_secret: "lab-secret"
```

## Usage

### List VMs

```bash
# List all VMs
pve vms

# Filter by name pattern
pve vms --filter "name=*k8s*"

# Filter by VMID
pve vms --filter "vmid=101"

# JSON output
pve vms --json
```

### Control VMs

```bash
# Start VM (async)
pve start --vmid 101

# Start VM and wait for completion
pve start --vmid 101 --wait

# Graceful shutdown
pve shutdown --vmid 101 --wait

# Force stop (requires confirmation)
pve stop --vmid 101 --yes --wait
```

### Snapshots

```bash
# Create snapshot
pve snapshot create --vmid 101 --name "pre-upgrade" --wait

# With description
pve snapshot create --vmid 101 --name "before-update" --desc "Before system update" --wait
```

### Backups

```bash
# Backup to storage (snapshot mode)
pve backup --vmid 101 --storage pbs --wait

# Different backup modes
pve backup --vmid 101 --storage local --mode suspend --wait
pve backup --vmid 101 --storage nfs --mode stop --wait
```

### Multiple Profiles

```bash
# Use specific profile
pve vms --profile production

# Override config with CLI flags
pve vms --host https://other-pve.com:8006 --token-id user@pve!token
```

## Development

### Setup Development Environment

```bash
# Clone and setup
cd pvecli
uv venv .venv
source .venv/bin/activate
uv pip install -e ".[dev]"

# Run tests
pytest

# Format code
black .

# Type checking
mypy pvecli/
```

### Building Binary

```bash
# Install PyInstaller
uv pip install pyinstaller

# Build single binary
pyinstaller --onefile --name pve pvecli/cli.py

# Binary will be in dist/pve
```

## API Token Setup

1. In Proxmox web interface, go to **Datacenter** → **Permissions** → **API Tokens**
2. Click **Add** and create a token for your user
3. **Important**: Uncheck "Privilege Separation" or assign appropriate permissions
4. Copy the Token ID and Secret

### Required Permissions

For the token user, assign these privileges:

- `VM.Audit` - List VMs
- `VM.PowerMgmt` - Start/stop VMs  
- `VM.Snapshot` - Create snapshots
- `VM.Backup` - Create backups

## Exit Codes

- `0` - Success
- `1` - General error (API error, task failed)  
- `2` - Resource not found (VMID not found)
- `3` - Timeout (task didn't complete in time)

## Roadmap

- **v0.2**: JMESPath queries, snapshot list/rollback, bulk operations
- **v0.3**: PBS integration, multi-OS builds  
- **v1.0**: RBAC documentation, signed releases
