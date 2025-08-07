#!/bin/bash

# Advanced Prometheus and Grafana Installation Script
# This script installs the Prometheus Operator stack using custom values

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="$SCRIPT_DIR/prometheus-values.yaml"

echo "🚀 Installing Prometheus and Grafana monitoring stack with custom configuration..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if cluster is accessible
echo "🔍 Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please ensure your kubeconfig is properly configured"
    exit 1
fi

# Add Prometheus community Helm repository
echo "📦 Adding Prometheus community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "📁 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Check if local-path storage class exists, if not suggest alternatives
echo "🔍 Checking storage classes..."
if kubectl get storageclass local-path &> /dev/null; then
    echo "✅ Using local-path storage class"
    STORAGE_CLASS="local-path"
elif kubectl get storageclass | grep -q "(default)"; then
    STORAGE_CLASS=$(kubectl get storageclass | grep "(default)" | awk '{print $1}')
    echo "✅ Using default storage class: $STORAGE_CLASS"
    # Update values file with default storage class
    sed -i.bak "s/storageClassName: local-path/storageClassName: $STORAGE_CLASS/g" "$VALUES_FILE"
else
    echo "⚠️  No default storage class found. You may need to:"
    echo "   1. Enable local-path-provisioner in Kubespray addons.yml"
    echo "   2. Or configure a different storage class in prometheus-values.yaml"
    kubectl get storageclass
fi

# Install kube-prometheus-stack
echo "⚙️ Installing kube-prometheus-stack with custom values..."
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values "$VALUES_FILE" \
  --wait \
  --timeout 10m

echo "✅ Prometheus stack installed successfully!"

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l "app.kubernetes.io/instance=prometheus-stack" -n monitoring --timeout=300s

# Display access information
echo ""
echo "🔐 Access Information:"
echo "===================="

# Get node IPs
NODE_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | tr ' ' '\n' | head -1)
if [ -z "$NODE_IPS" ]; then
    NODE_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' '\n' | head -1)
fi

echo "Grafana Dashboard:"
echo "  - URL: http://$NODE_IPS:30080"
echo "  - Username: admin"
echo "  - Password: secure-admin-password"
echo ""
echo "Prometheus UI:"
echo "  - URL: http://$NODE_IPS:30090"
echo ""
echo "Alertmanager UI:"
echo "  - URL: http://$NODE_IPS:30093"
echo ""

echo "📍 All node IPs:"
kubectl get nodes -o wide | awk 'NR==1{print $1"\t"$7} NR>1{print $1"\t"$7}' | column -t

echo ""
echo "🎯 Useful commands:"
echo "  - Check pods: kubectl get pods -n monitoring"
echo "  - Check services: kubectl get svc -n monitoring"
echo "  - Check persistent volumes: kubectl get pv"
echo "  - Port-forward Grafana: kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80"
echo "  - Port-forward Prometheus: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
echo "  - View Grafana admin password: kubectl get secret -n monitoring prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d"

echo ""
echo "📊 Popular Grafana Dashboards (already configured):"
echo "  - Node Exporter Full (ID: 1860) - Server metrics"
echo "  - Kubernetes Cluster Monitoring (ID: 7249) - Cluster overview"  
echo "  - Kubernetes Pods Monitoring (ID: 6417) - Pod metrics"

echo ""
echo "🔧 Next steps:"
echo "  1. Access Grafana and explore the pre-configured dashboards"
echo "  2. Configure alerting rules in Prometheus"
echo "  3. Set up notification channels in Alertmanager"
echo "  4. Import additional dashboards from https://grafana.com/grafana/dashboards/"
