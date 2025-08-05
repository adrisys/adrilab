# Kubernetes Cluster with Kubespray

This directory contains the configuration for deploying a Kubernetes cluster using Kubespray v2.28.0.

## Cluster Configuration

### Infrastructure Overview

- **1 Control Plane Node**: `master`
- **2 Worker Nodes**: `worker1`, `worker2`
- **Network Plugin**: Calico CNI
- **Topology**: Stacked etcd (runs on control plane node)

### Prerequisites

1. **SSH Access**: Ensure SSH key-based authentication is configured
   - Private key: `~/.ssh/id_rsa`
   - SSH user: `user`

2. **Python & Ansible**: Install dependencies on the deployment machine

   ```bash
   pip install -r requirements.txt
   ```

3. **Target Nodes**: All target nodes should have:
   - Ubuntu/Debian/CentOS/RHEL with sudo access
   - Python 3 installed
   - SSH access configured

## Installation

### 1. Update Inventory

Edit the inventory configuration in `inventory/mycluster/inventory.ini`:

- Replace IP addresses with your actual server IPs
- Update hostnames if needed
- Verify SSH connection details

### 2. Customize Configuration

Review and modify configuration files in `inventory/mycluster/group_vars/`:

- `all/all.yml`: Global cluster settings
- `k8s_cluster/k8s-cluster.yml`: Kubernetes-specific configuration
- `k8s_cluster/k8s-net-calico.yml`: Calico networking settings

### 3. Deploy the Cluster

Run the Kubespray playbook from the kubespray directory:

```bash
# From the kubespray-2.28.0 directory
ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml
```

### 4. Access the Cluster

After successful deployment, copy the kubeconfig:

```bash
# Copy kubeconfig from the master node
scp -i ~/.ssh/id_rsa user@<MASTER_IP>:/etc/kubernetes/admin.conf ~/.kube/config

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

## Configuration Highlights

### Networking

- **CNI Plugin**: Calico
- **Pod Subnet**: Default Kubernetes pod networking
- **Service Subnet**: Default Kubernetes service networking
- **Block Size**: /26 (64 IPs per node)

### Security

- **API Server**: Anonymous auth enabled (default)
- **SSH**: StrictHostKeyChecking disabled for automation
- **Certificates**: Auto-generated and managed by Kubespray

## Useful Commands

### Cluster Management

```bash
# Check cluster status
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# View cluster info
kubectl cluster-info

# Check Calico status
kubectl get pods -n kube-system | grep calico
```

### Scaling Operations

```bash
# Add nodes (update inventory first)
ansible-playbook -i inventory/mycluster/inventory.ini scale.yml

# Remove nodes
ansible-playbook -i inventory/mycluster/inventory.ini remove-node.yml -e node=nodename

# Upgrade cluster
ansible-playbook -i inventory/mycluster/inventory.ini upgrade-cluster.yml
```

### Maintenance

```bash
# Reset cluster (WARNING: Destructive operation)
ansible-playbook -i inventory/mycluster/inventory.ini reset.yml

# Recover control plane
ansible-playbook -i inventory/mycluster/inventory.ini recover-control-plane.yml
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**: Verify SSH keys and network connectivity
2. **Python Not Found**: Ensure Python 3 is installed on target nodes
3. **Permission Denied**: Check sudo access for the SSH user
4. **Network Plugin Issues**: Verify Calico pods are running

### Log Locations

- **Kubelet logs**: `journalctl -u kubelet`
- **Container logs**: `kubectl logs <pod-name> -n <namespace>`
- **Ansible logs**: Check Ansible output during deployment

## Directory Structure

```text
inventory/mycluster/
├── inventory.ini              # Node definitions and groups
├── group_vars/
│   ├── all/all.yml           # Global variables
│   ├── k8s_cluster/          # Kubernetes cluster settings
│   └── etcd.yml              # etcd configuration
└── credentials/              # Certificate and key storage
```

For more advanced configuration options, refer to the [official Kubespray documentation](https://kubespray.io/).
