#!/bin/bash

# Install ArgoCD on kubeadm cluster
# This script installs ArgoCD as a prerequisite for GitOps

set -e

echo "🚀 Installing ArgoCD on kubeadm cluster..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"

# Create ArgoCD namespace
echo "📁 Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=600s

# Get initial admin password
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ ArgoCD installed successfully!"
echo ""
echo "🔐 ArgoCD Access Information:"
echo "============================="
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "To access ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then open: https://localhost:8080"
echo ""
echo "📝 Save this password - the secret will be deleted after first login!"

# Optional: Patch ArgoCD server service to NodePort for easier access
read -p "Do you want to expose ArgoCD via NodePort? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌐 Exposing ArgoCD via NodePort..."
    kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8080,"nodePort":30443}]}}'
    
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    echo "ArgoCD will be available at: https://$NODE_IP:30443"
    echo "(Accept the self-signed certificate warning)"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Access ArgoCD UI with the credentials above"
echo "2. Run the monitoring deployment script: ./deploy-monitoring.sh"
