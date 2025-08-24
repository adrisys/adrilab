# PVE CLI Development Log

## Context
This project was built as a Proxmox VE CLI tool for learning Python and practicing CLI development.

## What We Built (v0.1.0 MVP)
- ✅ Complete CLI with 6 commands: `vms`, `start`, `shutdown`, `stop`, `snapshot create`, `backup`
- ✅ Configuration system: env vars, config files, CLI flags, profiles
- ✅ Clean output: tables + JSON, no urllib3 warnings
- ✅ Safety features: confirmation prompts, proper exit codes
- ✅ Task waiting with progress bars
- ✅ Filtering: `--filter name=*pattern*` or `--filter vmid=123`
- ✅ Test suite with 8 passing tests
- ✅ Standalone 7.2MB binary via PyInstaller
- ✅ Development workflow with Makefile

## Technology Stack
- **Language**: Python 3.8+ (running on 3.9.6)
- **CLI Framework**: Typer (modern, type-safe)
- **HTTP Client**: Requests + urllib3
- **Config**: PyYAML
- **UI**: Rich (colors, progress) + Tabulate (tables)
- **Testing**: pytest
- **Build**: PyInstaller for standalone binary
- **Package Manager**: uv (fast pip replacement)

## Project Structure
```
pvecli/
├── pvecli/cli.py        # Main CLI implementation (430 lines)
├── tests/               # Test suite
├── pyproject.toml       # Modern Python config
├── Makefile            # Development commands
├── build.py            # Binary builder
└── dist/pve            # Standalone binary (7.2MB)
```

## Key Features Demonstrated

### Configuration Management
```python
class PVEConfig:
    # Priority: CLI flags → ENV vars → config file → defaults
    # Multi-profile support for different environments
```

### API Client Pattern
```python
class PVEClient:
    # Centralized HTTP client with authentication
    # Node discovery and caching
    # Task waiting with timeouts
```

### Command Structure
```python
@app.command()
def start(vmid: int, wait: bool = False, ...):
    # Type-safe argument parsing
    # Consistent error handling
    # Rich progress indicators
```

## Working Commands (Tested)
```bash
# List VMs (your actual cluster)
./dist/pve vms
# Output: 19 VMs including worker1.lan, master.lan, etc.

# Filtering works
./dist/pve vms --filter "name=*lan*"  
# Shows: 6 VMs with 'lan' in name

# JSON output for scripts  
./dist/pve vms --json

# VM control (replace with your VMID)
./dist/pve start --vmid 103 --wait
./dist/pve shutdown --vmid 103 --wait
./dist/pve stop --vmid 103 --yes --wait

# Snapshots and backups
./dist/pve snapshot create --vmid 103 --name "test" --wait
./dist/pve backup --vmid 103 --storage pbs --wait
```

## API Endpoints Used
- `GET /cluster/resources?type=vm` - List VMs
- `POST /nodes/{node}/qemu/{vmid}/status/start` - Start VM
- `POST /nodes/{node}/qemu/{vmid}/status/shutdown` - Graceful shutdown
- `POST /nodes/{node}/qemu/{vmid}/status/stop?force=1` - Force stop
- `POST /nodes/{node}/qemu/{vmid}/snapshot` - Create snapshot
- `POST /nodes/{node}/vzdump` - Backup VM
- `GET /nodes/{node}/tasks/{upid}/status` - Task status

## Development Commands
```bash
make help          # Show all commands
make dev           # Install with dev dependencies
make test          # Run test suite
make binary        # Build standalone binary
make clean         # Clean build artifacts
```

## Authentication Setup
```yaml
# ~/.pvecli/config.yaml
host: "https://pve.adrilab.com:8006"
token_id: "pvecli@pam!pvecli"
token_secret: "dbac6d40-22a5-4dc1-af67-d0618a452584"
verify_ssl: false
```

## Next Steps for Learning
1. **Study the code** - understand each class and function
2. **Add features** - implement v0.2 features (JMESPath queries, snapshot list/rollback)
3. **Refactor sections** - practice by rewriting components
4. **Add more tests** - increase coverage
5. **Performance improvements** - caching, async, etc.

## Learning Opportunities
- **Error handling patterns** - see how API errors are caught and converted to user-friendly messages
- **Configuration management** - multiple sources with priority
- **Testing strategies** - mocking API calls, CLI testing
- **Binary distribution** - PyInstaller configuration and optimization
- **Type hints** - modern Python typing throughout

## Original Conversation
The complete conversation that built this is saved separately - reference it for the step-by-step process and decision-making rationale.
