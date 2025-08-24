#!/usr/bin/env python3
"""
Proxmox VE CLI - A simple CLI for managing Proxmox VE virtual machines.
"""

# Suppress urllib3 warnings early
import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="urllib3")
warnings.filterwarnings("ignore", message=".*urllib3 v2 only supports OpenSSL.*")
warnings.filterwarnings("ignore", message=".*Unverified HTTPS request.*")

import os
import time
import sys
import json
import glob
from pathlib import Path
from typing import Optional, Dict, Any, List

import typer
import requests
import yaml
from tabulate import tabulate
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn

# Additional urllib3 warning suppression
import urllib3
urllib3.disable_warnings()
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = typer.Typer(
    name="pve",
    help="Proxmox VE CLI - Manage virtual machines from the command line",
    add_completion=False,
)
console = Console()

API_PREFIX = "/api2/json"


class PVEConfig:
    """Configuration management for PVE CLI."""

    def __init__(
        self,
        host: Optional[str] = None,
        token_id: Optional[str] = None,
        token_secret: Optional[str] = None,
        verify_ssl: Optional[bool] = None,
        profile: str = "default",
    ):
        self.config = self._load_config()
        self.profile = profile
        
        # Override with explicit parameters or env vars
        self.host = host or os.getenv("PVE_HOST") or self._get_config_value("host")
        self.token_id = (
            token_id or os.getenv("PVE_TOKEN_ID") or self._get_config_value("token_id")
        )
        self.token_secret = (
            token_secret
            or os.getenv("PVE_TOKEN_SECRET")
            or self._get_config_value("token_secret")
        )
        self.verify_ssl = (
            verify_ssl
            if verify_ssl is not None
            else os.getenv("PVE_VERIFY_SSL", "false").lower() == "true"
            or self._get_config_value("verify_ssl", False)
        )

        if not all([self.host, self.token_id, self.token_secret]):
            console.print(
                "[red]Error: Missing required configuration. Set PVE_HOST, PVE_TOKEN_ID, and PVE_TOKEN_SECRET environment variables or create ~/.pvecli/config.yaml[/red]"
            )
            raise typer.Exit(1)

    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from ~/.pvecli/config.yaml."""
        config_path = Path.home() / ".pvecli" / "config.yaml"
        if config_path.exists():
            with open(config_path, "r") as f:
                return yaml.safe_load(f) or {}
        return {}

    def _get_config_value(self, key: str, default: Any = None) -> Any:
        """Get configuration value from profile or default."""
        profiles = self.config.get("profiles", {})
        profile_config = profiles.get(self.profile, {})
        return profile_config.get(key, self.config.get(key, default))


class PVEClient:
    """Proxmox VE API client."""

    def __init__(self, config: PVEConfig):
        self.config = config
        self._node_cache: Optional[Dict[str, str]] = None

    def _auth_headers(self) -> Dict[str, str]:
        """Get authentication headers."""
        return {
            "Authorization": f"PVEAPIToken={self.config.token_id}={self.config.token_secret}"
        }

    def _request(
        self, method: str, path: str, params: Optional[Dict] = None, data: Optional[Dict] = None
    ) -> Any:
        """Make API request to Proxmox VE."""
        url = f"{self.config.host}{API_PREFIX}{path}"
        headers = self._auth_headers()
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=headers,
                params=params,
                data=data,
                verify=self.config.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()
            return response.json().get("data")
        except requests.exceptions.RequestException as e:
            console.print(f"[red]API Error: {e}[/red]")
            raise typer.Exit(1)

    def get(self, path: str, params: Optional[Dict] = None) -> Any:
        """GET request."""
        return self._request("GET", path, params=params)

    def post(self, path: str, data: Optional[Dict] = None) -> Any:
        """POST request."""
        return self._request("POST", path, data=data)

    def get_node_by_vmid(self, vmid: int) -> str:
        """Get the node hosting a specific VMID."""
        if not self._node_cache:
            self._build_node_cache()
        
        vmid_str = str(vmid)
        if vmid_str in self._node_cache:
            return self._node_cache[vmid_str]
        
        console.print(f"[red]VMID {vmid} not found in cluster[/red]")
        raise typer.Exit(2)

    def _build_node_cache(self) -> None:
        """Build cache of vmid -> node mapping."""
        resources = self.get("/cluster/resources", params={"type": "vm"})
        self._node_cache = {}
        for resource in resources:
            if "vmid" in resource and "node" in resource:
                self._node_cache[str(resource["vmid"])] = resource["node"]

    def wait_for_task(self, node: str, upid: str, timeout: int = 900) -> str:
        """Wait for a task to complete and return exit status."""
        start_time = time.time()
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            task = progress.add_task("Waiting for task to complete...", total=None)
            
            while True:
                status_data = self.get(f"/nodes/{node}/tasks/{upid}/status")
                status = status_data.get("status")
                
                if status == "stopped":
                    exit_status = status_data.get("exitstatus", "unknown")
                    progress.update(task, description="Task completed")
                    return exit_status
                
                if time.time() - start_time > timeout:
                    console.print(f"[red]Task timeout after {timeout}s: {upid}[/red]")
                    raise typer.Exit(3)
                
                time.sleep(1)


def apply_name_filter(vms: List[Dict], filter_value: str) -> List[Dict]:
    """Apply name filter using glob pattern."""
    filtered = []
    for vm in vms:
        vm_name = vm.get("name", "")
        if glob.fnmatch.fnmatch(vm_name, filter_value):
            filtered.append(vm)
    return filtered


def apply_vmid_filter(vms: List[Dict], filter_value: str) -> List[Dict]:
    """Apply VMID filter."""
    try:
        target_vmid = int(filter_value)
        return [vm for vm in vms if vm.get("vmid") == target_vmid]
    except ValueError:
        console.print(f"[red]Invalid VMID filter: {filter_value}[/red]")
        raise typer.Exit(1)


@app.command()
def vms(
    filter: Optional[str] = typer.Option(None, help="Filter VMs (name=<glob> or vmid=<id>)"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """List virtual machines in the cluster."""
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    vms_data = client.get("/cluster/resources", params={"type": "vm"})
    
    # Apply filters
    if filter:
        if "=" not in filter:
            console.print("[red]Filter must be in format: name=<glob> or vmid=<id>[/red]")
            raise typer.Exit(1)
        
        filter_type, filter_value = filter.split("=", 1)
        if filter_type == "name":
            vms_data = apply_name_filter(vms_data, filter_value)
        elif filter_type == "vmid":
            vms_data = apply_vmid_filter(vms_data, filter_value)
        else:
            console.print(f"[red]Unknown filter type: {filter_type}[/red]")
            raise typer.Exit(1)
    
    if json_output:
        print(json.dumps(vms_data, indent=2))
    else:
        # Format as table
        headers = ["Node", "VMID", "Name", "Status"]
        rows = []
        for vm in vms_data:
            rows.append([
                vm.get("node", ""),
                vm.get("vmid", ""),
                vm.get("name", ""),
                vm.get("status", "")
            ])
        
        if rows:
            print(tabulate(rows, headers=headers, tablefmt="simple"))
        else:
            console.print("[yellow]No VMs found matching criteria[/yellow]")


@app.command()
def start(
    vmid: int = typer.Option(..., help="Virtual machine ID"),
    wait: bool = typer.Option(False, help="Wait for task completion"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """Start a virtual machine."""
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    node = client.get_node_by_vmid(vmid)
    upid = client.post(f"/nodes/{node}/qemu/{vmid}/status/start")
    
    if wait:
        exit_status = client.wait_for_task(node, upid)
        if exit_status == "OK":
            console.print(f"[green]VM {vmid} started successfully[/green]")
        else:
            console.print(f"[red]VM {vmid} start failed with status: {exit_status}[/red]")
            raise typer.Exit(1)
    else:
        console.print(f"Start task initiated for VM {vmid}: {upid}")


@app.command()
def shutdown(
    vmid: int = typer.Option(..., help="Virtual machine ID"),
    wait: bool = typer.Option(False, help="Wait for task completion"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """Gracefully shutdown a virtual machine."""
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    node = client.get_node_by_vmid(vmid)
    upid = client.post(f"/nodes/{node}/qemu/{vmid}/status/shutdown")
    
    if wait:
        exit_status = client.wait_for_task(node, upid)
        if exit_status == "OK":
            console.print(f"[green]VM {vmid} shutdown successfully[/green]")
        else:
            console.print(f"[red]VM {vmid} shutdown failed with status: {exit_status}[/red]")
            raise typer.Exit(1)
    else:
        console.print(f"Shutdown task initiated for VM {vmid}: {upid}")


@app.command()
def stop(
    vmid: int = typer.Option(..., help="Virtual machine ID"),
    wait: bool = typer.Option(False, help="Wait for task completion"),
    force: bool = typer.Option(False, help="Force stop (same as default behavior)"),
    yes: bool = typer.Option(False, help="Skip confirmation prompt"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """Force stop a virtual machine."""
    if not yes and sys.stdin.isatty():
        confirm = typer.confirm(f"Force stop VM {vmid}? This may cause data loss.")
        if not confirm:
            console.print("Operation cancelled")
            raise typer.Exit(0)
    elif not yes:
        console.print("[red]Use --yes to confirm destructive operation in non-interactive mode[/red]")
        raise typer.Exit(1)
    
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    node = client.get_node_by_vmid(vmid)
    upid = client.post(f"/nodes/{node}/qemu/{vmid}/status/stop", data={"force": "1"})
    
    if wait:
        exit_status = client.wait_for_task(node, upid)
        if exit_status == "OK":
            console.print(f"[green]VM {vmid} stopped successfully[/green]")
        else:
            console.print(f"[red]VM {vmid} stop failed with status: {exit_status}[/red]")
            raise typer.Exit(1)
    else:
        console.print(f"Stop task initiated for VM {vmid}: {upid}")


@app.command()
def snapshot(
    action: str = typer.Argument(..., help="Action: create"),
    vmid: int = typer.Option(..., help="Virtual machine ID"),
    name: str = typer.Option(..., help="Snapshot name"),
    desc: Optional[str] = typer.Option(None, help="Snapshot description"),
    wait: bool = typer.Option(False, help="Wait for task completion"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """Manage virtual machine snapshots."""
    if action != "create":
        console.print(f"[red]Unknown action: {action}. Only 'create' is supported in v0.1[/red]")
        raise typer.Exit(1)
    
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    node = client.get_node_by_vmid(vmid)
    
    data = {"snapname": name}
    if desc:
        data["description"] = desc
    
    upid = client.post(f"/nodes/{node}/qemu/{vmid}/snapshot", data=data)
    
    if wait:
        exit_status = client.wait_for_task(node, upid)
        if exit_status == "OK":
            console.print(f"[green]Snapshot '{name}' created successfully for VM {vmid}[/green]")
        else:
            console.print(f"[red]Snapshot creation failed with status: {exit_status}[/red]")
            raise typer.Exit(1)
    else:
        console.print(f"Snapshot creation task initiated for VM {vmid}: {upid}")


@app.command()
def backup(
    vmid: int = typer.Option(..., help="Virtual machine ID"),
    storage: str = typer.Option(..., help="Storage name"),
    mode: str = typer.Option("snapshot", help="Backup mode: snapshot, suspend, or stop"),
    wait: bool = typer.Option(False, help="Wait for task completion"),
    host: Optional[str] = typer.Option(None, help="Proxmox host"),
    token_id: Optional[str] = typer.Option(None, help="API token ID"),
    token_secret: Optional[str] = typer.Option(None, help="API token secret"),
    verify_ssl: bool = typer.Option(False, help="Verify SSL certificates"),
    profile: str = typer.Option("default", help="Configuration profile"),
):
    """Backup a virtual machine."""
    if mode not in ["snapshot", "suspend", "stop"]:
        console.print(f"[red]Invalid mode: {mode}. Use snapshot, suspend, or stop[/red]")
        raise typer.Exit(1)
    
    config = PVEConfig(host, token_id, token_secret, verify_ssl, profile)
    client = PVEClient(config)
    
    node = client.get_node_by_vmid(vmid)
    
    data = {
        "vmid": str(vmid),
        "storage": storage,
        "mode": mode,
        "compress": "zstd",
    }
    
    upid = client.post(f"/nodes/{node}/vzdump", data=data)
    
    if wait:
        exit_status = client.wait_for_task(node, upid)
        if exit_status == "OK":
            console.print(f"[green]Backup completed successfully for VM {vmid}[/green]")
        else:
            console.print(f"[red]Backup failed with status: {exit_status}[/red]")
            raise typer.Exit(1)
    else:
        console.print(f"Backup task initiated for VM {vmid}: {upid}")


if __name__ == "__main__":
    app()
