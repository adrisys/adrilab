"""Test configuration for pvecli."""

import pytest
from unittest.mock import Mock, patch
from pvecli.cli import PVEConfig, PVEClient


@pytest.fixture
def mock_config():
    """Mock configuration for testing."""
    with patch.dict("os.environ", {
        "PVE_HOST": "https://test.example.com:8006",
        "PVE_TOKEN_ID": "test@pve!token",
        "PVE_TOKEN_SECRET": "test-secret",
        "PVE_VERIFY_SSL": "false"
    }):
        yield PVEConfig()


@pytest.fixture
def mock_client(mock_config):
    """Mock PVE client for testing."""
    return PVEClient(mock_config)


@pytest.fixture
def sample_vms_data():
    """Sample VM data for testing."""
    return [
        {
            "node": "node1",
            "vmid": 101,
            "name": "test-vm-1",
            "status": "running"
        },
        {
            "node": "node2", 
            "vmid": 102,
            "name": "k8s-master",
            "status": "stopped"
        },
        {
            "node": "node1",
            "vmid": 103, 
            "name": "k8s-worker-1",
            "status": "running"
        }
    ]
