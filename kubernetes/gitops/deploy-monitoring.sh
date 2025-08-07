#!/bin/bash

# GitOps Monitoring Stack Deployment Script
# This script sets up the monitoring stack using GitOps approach with ArgoCD

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITOPS_DIR="$SCRIPT_DIR"
REPO_URL="https://github.com/adrisys/adrilab.git"  # Update with your repo URL

echo "🚀 Deploying Monitoring Stack via GitOps (ArgoCD)"
echo "================================================"

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ ArgoCD namespace not found. Please install ArgoCD first:"
    echo "   Run: ./install-argocd.sh"
    exit 1
fi

# Check if monitoring secrets exist
if ! kubectl get secret grafana-admin-credentials -n monitoring &> /dev/null 2>&1; then
    echo "⚠️  Monitoring secrets not found. Setting up secure credentials..."
    echo "   Run: ./setup-monitoring-secrets.sh"
    read -p "Do you want to run the secure setup now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./setup-monitoring-secrets.sh
    else
        echo "❌ Please run ./setup-monitoring-secrets.sh first to set up secure credentials"
        exit 1
    fi
fi

echo "✅ Prerequisites check passed"

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Update repository URL in manifests (if needed)
if [ "$1" != "" ]; then
    REPO_URL="$1"
    echo "📝 Using custom repository URL: $REPO_URL"
    
    # Update the app-of-apps manifest
    sed -i.bak "s|repoURL: .*|repoURL: $REPO_URL|g" "$GITOPS_DIR/app-of-apps.yaml"
    sed -i.bak "s|repoURL: .*|repoURL: $REPO_URL|g" "$GITOPS_DIR/applications/monitoring.yaml"
fi

# Deploy the App of Apps
echo "📦 Deploying App of Apps..."
kubectl apply -f "$GITOPS_DIR/app-of-apps.yaml"

# Wait a moment and deploy monitoring application directly as well (fallback)
sleep 5
echo "📦 Deploying Monitoring Application..."
kubectl apply -f "$GITOPS_DIR/applications/monitoring.yaml"

echo "⏳ Waiting for applications to sync..."
sleep 10

# Check ArgoCD application status
echo "📊 ArgoCD Application Status:"
kubectl get applications -n argocd

echo ""
echo "🔐 ArgoCD Access Information:"
echo "============================="

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "Unable to retrieve password")

echo "ArgoCD UI:"
echo "  - Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  - URL: https://localhost:8080"
echo "  - Username: admin"
echo "  - Password: $ARGOCD_PASSWORD"

# Wait for monitoring namespace to be created
echo ""
echo "⏳ Waiting for monitoring components to be deployed..."
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
    
    # Wait for some pods to be ready
    echo "⏳ Waiting for monitoring pods to start..."
    sleep 30
    
    echo ""
    echo "📊 Monitoring Stack Status:"
    echo "============================"
    kubectl get pods -n monitoring
    
    echo ""
    echo "🌐 Monitoring Access Information:"
    echo "=================================="
    
    # Get node IPs
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    
    echo "Grafana Dashboard:"
    echo "  - URL: http://$NODE_IP:30080"
    echo "  - Username: admin"
    echo "  - Password: Check ArgoCD application or run:"
    echo "    kubectl get secret -n monitoring prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
    
    echo ""
    echo "Prometheus UI:"
    echo "  - URL: http://$NODE_IP:30090"
    
    echo ""
    echo "Alertmanager UI:"
    echo "  - URL: http://$NODE_IP:30093"
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Access ArgoCD UI to monitor deployments"
echo "2. Check application sync status: kubectl get applications -n argocd"
echo "3. If sync fails, check: kubectl describe application monitoring -n argocd"
echo "4. Access Grafana and explore the dashboards"
echo "5. Configure alerting rules and notification channels as needed"

echo ""
echo "🔧 Useful Commands:"
echo "==================="
echo "# Sync applications manually"
echo "kubectl patch application monitoring -n argocd --type merge --patch '{\"operation\":{\"initiatedBy\":{\"username\":\"admin\"},\"sync\":{\"revision\":\"HEAD\"}}}'"
echo ""
echo "# Check monitoring pods"
echo "kubectl get pods -n monitoring"
echo ""
echo "# Port-forward services locally"
echo "kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80"
echo "kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
