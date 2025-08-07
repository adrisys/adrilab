#!/bin/bash

# Complete monitoring stack setup for kubeadm cluster
# This script sets up storage, ArgoCD, and monitoring stack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/adrisys/adrilab.git"

echo "🚀 Complete Monitoring Stack Setup for kubeadm"
echo "==============================================="

# Parse command line arguments
SKIP_ARGOCD=false
SKIP_STORAGE=false
STORAGE_CLASS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-argocd)
            SKIP_ARGOCD=true
            shift
            ;;
        --skip-storage)
            SKIP_STORAGE=true
            shift
            ;;
        --storage-class=*)
            STORAGE_CLASS="${1#*=}"
            shift
            ;;
        --repo=*)
            REPO_URL="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-argocd] [--skip-storage] [--storage-class=name] [--repo=url]"
            exit 1
            ;;
    esac
done

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Connected to cluster: $(kubectl config current-context)"

# Step 1: Setup storage if needed
if [ "$SKIP_STORAGE" = false ]; then
    echo ""
    echo "🗄️  Step 1: Storage Setup"
    echo "========================"
    
    # Check for existing default storage class
    if kubectl get storageclass 2>/dev/null | grep -q "(default)"; then
        DEFAULT_SC=$(kubectl get storageclass | grep "(default)" | awk '{print $1}')
        echo "✅ Default storage class found: $DEFAULT_SC"
        STORAGE_CLASS="$DEFAULT_SC"
    else
        echo "📦 No default storage class found. Installing local-path-provisioner..."
        if [ -f "$SCRIPT_DIR/setup-storage.sh" ]; then
            bash "$SCRIPT_DIR/setup-storage.sh"
            STORAGE_CLASS="local-path"
        else
            echo "❌ setup-storage.sh not found"
            exit 1
        fi
    fi
else
    echo "⏭️  Skipping storage setup"
    if [ -z "$STORAGE_CLASS" ]; then
        STORAGE_CLASS=$(kubectl get storageclass | grep "(default)" | awk '{print $1}' || echo "local-path")
    fi
fi

# Step 2: Install ArgoCD if needed
if [ "$SKIP_ARGOCD" = false ]; then
    echo ""
    echo "🔄 Step 2: ArgoCD Setup"
    echo "======================="
    
    if kubectl get namespace argocd &> /dev/null; then
        echo "✅ ArgoCD already installed"
    else
        echo "📦 Installing ArgoCD..."
        if [ -f "$SCRIPT_DIR/install-argocd.sh" ]; then
            bash "$SCRIPT_DIR/install-argocd.sh"
        else
            echo "❌ install-argocd.sh not found"
            exit 1
        fi
    fi
else
    echo "⏭️  Skipping ArgoCD installation"
fi

# Step 3: Update monitoring configuration for detected storage class
echo ""
echo "🔧 Step 3: Configure Monitoring Stack"
echo "====================================="

echo "📝 Using storage class: $STORAGE_CLASS"

# Create a temporary patch file with the correct storage class
TEMP_PATCH=$(mktemp)
cat > "$TEMP_PATCH" << EOF
- op: replace
  path: /spec/source/helm/values
  value: |
    global:
      rbac:
        create: true

    prometheus:
      prometheusSpec:
        storageSpec:
          volumeClaimTemplate:
            spec:
              storageClassName: $STORAGE_CLASS
              resources:
                requests:
                  storage: 20Gi
        retention: 30d
        retentionSize: 15GB
        resources:
          limits:
            cpu: 1000m
            memory: 4Gi
          requests:
            cpu: 500m
            memory: 2Gi
        serviceMonitorSelectorNilUsesHelmValues: false
        podMonitorSelectorNilUsesHelmValues: false
        ruleSelectorNilUsesHelmValues: false
      service:
        type: NodePort
        nodePort: 30090

    grafana:
      adminPassword: "admin123"
      persistence:
        enabled: true
        storageClassName: $STORAGE_CLASS
        size: 10Gi
      service:
        type: NodePort
        nodePort: 30080
      resources:
        limits:
          cpu: 500m
          memory: 1Gi
        requests:
          cpu: 100m
          memory: 256Mi
      defaultDashboardsEnabled: true
      sidecar:
        dashboards:
          enabled: true
          label: grafana_dashboard
          labelValue: "1"
        datasources:
          enabled: true
          label: grafana_datasource
          labelValue: "1"

    alertmanager:
      alertmanagerSpec:
        storage:
          volumeClaimTemplate:
            spec:
              storageClassName: $STORAGE_CLASS
              resources:
                requests:
                  storage: 5Gi
        resources:
          limits:
            cpu: 200m
            memory: 512Mi
          requests:
            cpu: 50m
            memory: 128Mi
      service:
        type: NodePort
        nodePort: 30093

    nodeExporter:
      enabled: true
    kubeStateMetrics:
      enabled: true
    prometheusOperator:
      enabled: true
    kubeApiServer:
      enabled: true
    kubelet:
      enabled: true
    kubeControllerManager:
      enabled: true
    coreDns:
      enabled: true
    kubeEtcd:
      enabled: true
    kubeScheduler:
      enabled: true
    kubeProxy:
      enabled: true
EOF

# Update the patch file
cp "$TEMP_PATCH" "$SCRIPT_DIR/infrastructure/monitoring/overlays/production/prometheus-production-patch.yaml"
rm "$TEMP_PATCH"

# Update repository URLs
echo "📝 Updating repository URLs to: $REPO_URL"
sed -i.bak "s|repoURL: .*|repoURL: $REPO_URL|g" "$SCRIPT_DIR/app-of-apps.yaml"
sed -i.bak "s|repoURL: .*|repoURL: $REPO_URL|g" "$SCRIPT_DIR/applications/monitoring.yaml"

# Step 4: Deploy monitoring stack
echo ""
echo "🚀 Step 4: Deploy Monitoring Stack"
echo "==================================="

echo "📦 Deploying ArgoCD applications..."
kubectl apply -f "$SCRIPT_DIR/applications/monitoring.yaml"

echo "⏳ Waiting for monitoring deployment..."
sleep 30

# Wait for monitoring namespace
timeout=300
counter=0
while ! kubectl get namespace monitoring &> /dev/null; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for monitoring namespace"
        break
    fi
    sleep 5
    counter=$((counter + 5))
    echo -n "."
done

if kubectl get namespace monitoring &> /dev/null; then
    echo ""
    echo "✅ Monitoring namespace created"
    
    # Wait for pods
    echo "⏳ Waiting for monitoring pods..."
    sleep 60
    
    # Show status
    echo ""
    echo "📊 Deployment Status:"
    kubectl get applications -n argocd | grep monitoring || echo "ArgoCD application not found"
    echo ""
    kubectl get pods -n monitoring 2>/dev/null || echo "Monitoring pods not ready yet"
fi

# Step 5: Display access information
echo ""
echo "🎉 Setup Complete!"
echo "=================="

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo ""
echo "🔐 Access Information:"
echo "======================"

# ArgoCD info
if kubectl get namespace argocd &> /dev/null; then
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "Not available")
    echo "ArgoCD UI:"
    echo "  - URL: https://$NODE_IP:30443 (if NodePort enabled)"
    echo "  - Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "  - Username: admin"
    echo "  - Password: $ARGOCD_PASSWORD"
    echo ""
fi

echo "Grafana Dashboard:"
echo "  - URL: http://$NODE_IP:30080"
echo "  - Username: admin"
echo "  - Password: admin123"
echo ""
echo "Prometheus UI:"
echo "  - URL: http://$NODE_IP:30090"
echo ""
echo "Alertmanager UI:"
echo "  - URL: http://$NODE_IP:30093"

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Wait for all pods to be ready: watch kubectl get pods -n monitoring"
echo "2. Access Grafana and explore the pre-configured dashboards"
echo "3. Configure alert rules in Prometheus"
echo "4. Set up notification channels in Alertmanager"
echo ""
echo "🔧 Troubleshooting:"
echo "==================="
echo "# Check ArgoCD application status"
echo "kubectl get applications -n argocd"
echo "kubectl describe application monitoring -n argocd"
echo ""
echo "# Check monitoring pods"
echo "kubectl get pods -n monitoring"
echo "kubectl logs -n monitoring -l app.kubernetes.io/name=grafana"
