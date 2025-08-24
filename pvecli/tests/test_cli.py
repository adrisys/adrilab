"""Test basic CLI functionality."""

import pytest
from unittest.mock import Mock, patch
from typer.testing import CliRunner

from pvecli.cli import app, apply_name_filter, apply_vmid_filter


runner = CliRunner()


def test_apply_name_filter(sample_vms_data):
    """Test name filtering with glob patterns."""
    # Filter for k8s VMs
    result = apply_name_filter(sample_vms_data, "*k8s*")
    assert len(result) == 2
    assert all("k8s" in vm["name"] for vm in result)
    
    # Filter for exact match
    result = apply_name_filter(sample_vms_data, "test-vm-1")
    assert len(result) == 1
    assert result[0]["name"] == "test-vm-1"
    
    # No matches
    result = apply_name_filter(sample_vms_data, "*nonexistent*")
    assert len(result) == 0


def test_apply_vmid_filter(sample_vms_data):
    """Test VMID filtering."""
    result = apply_vmid_filter(sample_vms_data, "101")
    assert len(result) == 1
    assert result[0]["vmid"] == 101
    
    # No matches
    result = apply_vmid_filter(sample_vms_data, "999")
    assert len(result) == 0


def test_apply_vmid_filter_invalid():
    """Test invalid VMID filter."""
    from typer import Exit
    with pytest.raises(Exit):
        apply_vmid_filter([], "invalid")


@patch("pvecli.cli.PVEClient")
@patch("pvecli.cli.PVEConfig")
def test_vms_command_basic(mock_config_class, mock_client_class, sample_vms_data):
    """Test basic vms command."""
    # Setup mocks
    mock_config = Mock()
    mock_config_class.return_value = mock_config
    
    mock_client = Mock()
    mock_client_class.return_value = mock_client
    mock_client.get.return_value = sample_vms_data
    
    # Run command
    result = runner.invoke(app, ["vms"])
    
    # Verify
    assert result.exit_code == 0
    assert "node1" in result.stdout
    assert "test-vm-1" in result.stdout
    mock_client.get.assert_called_once_with("/cluster/resources", params={"type": "vm"})


@patch("pvecli.cli.PVEClient")
@patch("pvecli.cli.PVEConfig")
def test_vms_command_json(mock_config_class, mock_client_class, sample_vms_data):
    """Test vms command with JSON output."""
    # Setup mocks
    mock_config = Mock()
    mock_config_class.return_value = mock_config
    
    mock_client = Mock()
    mock_client_class.return_value = mock_client
    mock_client.get.return_value = sample_vms_data
    
    # Run command
    result = runner.invoke(app, ["vms", "--json"])
    
    # Verify
    assert result.exit_code == 0
    assert '"vmid": 101' in result.stdout
    assert '"name": "test-vm-1"' in result.stdout


@patch("pvecli.cli.PVEClient")
@patch("pvecli.cli.PVEConfig")
def test_start_command(mock_config_class, mock_client_class):
    """Test start command."""
    # Setup mocks
    mock_config = Mock()
    mock_config_class.return_value = mock_config
    
    mock_client = Mock()
    mock_client_class.return_value = mock_client
    mock_client.get_node_by_vmid.return_value = "node1"
    mock_client.post.return_value = "UPID:node1:123:456:start:101:user@pve:"
    
    # Run command
    result = runner.invoke(app, ["start", "--vmid", "101"])
    
    # Verify
    assert result.exit_code == 0
    assert "Start task initiated" in result.stdout
    mock_client.get_node_by_vmid.assert_called_once_with(101)
    mock_client.post.assert_called_once_with("/nodes/node1/qemu/101/status/start")


@patch("pvecli.cli.PVEClient")
@patch("pvecli.cli.PVEConfig") 
def test_start_command_with_wait(mock_config_class, mock_client_class):
    """Test start command with wait."""
    # Setup mocks
    mock_config = Mock()
    mock_config_class.return_value = mock_config
    
    mock_client = Mock()
    mock_client_class.return_value = mock_client
    mock_client.get_node_by_vmid.return_value = "node1"
    mock_client.post.return_value = "UPID:node1:123:456:start:101:user@pve:"
    mock_client.wait_for_task.return_value = "OK"
    
    # Run command
    result = runner.invoke(app, ["start", "--vmid", "101", "--wait"])
    
    # Verify
    assert result.exit_code == 0
    assert "started successfully" in result.stdout
    mock_client.wait_for_task.assert_called_once()


@patch("pvecli.cli.PVEClient")
@patch("pvecli.cli.PVEConfig")
def test_snapshot_create(mock_config_class, mock_client_class):
    """Test snapshot create command."""
    # Setup mocks  
    mock_config = Mock()
    mock_config_class.return_value = mock_config
    
    mock_client = Mock()
    mock_client_class.return_value = mock_client
    mock_client.get_node_by_vmid.return_value = "node1"
    mock_client.post.return_value = "UPID:node1:123:456:snapshot:101:user@pve:"
    
    # Run command
    result = runner.invoke(app, ["snapshot", "create", "--vmid", "101", "--name", "test-snap"])
    
    # Verify
    assert result.exit_code == 0
    assert "Snapshot creation task initiated" in result.stdout
    mock_client.post.assert_called_once_with(
        "/nodes/node1/qemu/101/snapshot", 
        data={"snapname": "test-snap"}
    )
