# GitOps Infrastructure Management

This directory contains GitOps configurations for managing infrastructure components using ArgoCD and Kustomize.

## Structure

```
gitops/
├── app-of-apps.yaml                    # Root ArgoCD Application (App of Apps pattern)
├── applications/                       # Individual application definitions
│   └── monitoring.yaml                 # Monitoring stack application
└── infrastructure/                     # Infrastructure component manifests
    └── monitoring/                     # Prometheus + Grafana monitoring stack
        ├── base/                       # Base configuration
        │   ├── kustomization.yaml
        │   ├── namespace.yaml
        │   └── prometheus-helm-release.yaml
        └── overlays/                   # Environment-specific overlays
            └── production/             # Production environment
                ├── kustomization.yaml
                ├── prometheus-production-patch.yaml
                └── dashboards/
                    └── kubernetes-overview.json
```

## Prerequisites

1. **Kubespray with ArgoCD enabled**: Ensure `argocd_enabled: true` in your Kubespray addons.yml
2. **Storage Class**: Configure `local-path` or update storage class in the configurations
3. **Git Repository**: Update repository URLs in the application manifests

## Getting Started

### 1. Deploy ArgoCD (via Kubespray)

First, ensure ArgoCD is enabled in your Kubespray configuration and deploy:

```bash
# Navigate to your Kubespray directory
cd kubernetes/kubespray-2.28.0

# Run the playbook to install ArgoCD
ansible-playbook -i inventory/mycluster/inventory.ini playbooks/cluster.yml --tags argocd
```

### 2. Access ArgoCD

Get the ArgoCD admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Port-forward to access ArgoCD UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access: https://localhost:8080 (username: admin)

### 3. Deploy the App of Apps

```bash
# Deploy the root application
kubectl apply -f kubernetes/gitops/app-of-apps.yaml

# Or deploy monitoring directly
kubectl apply -f kubernetes/gitops/applications/monitoring.yaml
```

### 4. Verify Deployment

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check monitoring namespace
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring
```

## Access Information

### Grafana Dashboard
- **URL**: http://your-node-ip:30080
- **Username**: admin
- **Password**: Check the production patch or use: 
  ```bash
  kubectl get secret -n monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d
  ```

### Prometheus UI
- **URL**: http://your-node-ip:30090

### Alertmanager UI
- **URL**: http://your-node-ip:30093

## Customization

### Adding Custom Dashboards

1. Add JSON dashboard files to `overlays/production/dashboards/`
2. Update `kustomization.yaml` to include the new dashboard
3. Commit and push - ArgoCD will sync automatically

### Environment-Specific Configurations

Create new overlays for different environments:

```bash
# Create staging overlay
mkdir -p infrastructure/monitoring/overlays/staging
cp -r infrastructure/monitoring/overlays/production/* infrastructure/monitoring/overlays/staging/
# Modify staging-specific configurations
```

### Modifying Resource Limits

Edit the patch files in `overlays/production/prometheus-production-patch.yaml` to adjust:
- CPU and memory limits
- Storage sizes
- Retention policies
- Service configurations

## Security Considerations

1. **Secrets Management**: Consider using external secret management (e.g., External Secrets Operator)
2. **RBAC**: Review and customize RBAC permissions
3. **Network Policies**: Implement network policies for production environments
4. **TLS**: Configure TLS certificates for production deployments

## Monitoring Components

The stack includes:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and management
- **Node Exporter**: Node-level metrics
- **Kube State Metrics**: Kubernetes resource metrics
- **Prometheus Operator**: Manages Prometheus resources

## Troubleshooting

### Check ArgoCD Application Status
```bash
kubectl get applications -n argocd
kubectl describe application monitoring -n argocd
```

### Check Monitoring Pods
```bash
kubectl get pods -n monitoring
kubectl logs -n monitoring deployment/prometheus-stack-grafana
```

### Force Sync
```bash
# Via CLI
argocd app sync monitoring

# Or delete and recreate
kubectl delete application monitoring -n argocd
kubectl apply -f kubernetes/gitops/applications/monitoring.yaml
```

## Best Practices

1. **Version Control**: All changes should go through Git
2. **Pull Requests**: Use PR reviews for configuration changes
3. **Testing**: Test changes in staging before production
4. **Monitoring**: Monitor the monitoring stack itself
5. **Backups**: Regular backups of Grafana dashboards and Prometheus data
6. **Documentation**: Keep this README updated with changes
