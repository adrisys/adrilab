#!/bin/bash

# Secure Monitoring Secrets Setup
# This script creates secure passwords for the monitoring stack
# Run this BEFORE deploying the monitoring stack

set -e

echo "🔐 Setting up secure monitoring credentials..."
echo "=============================================="

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

# Create monitoring namespace if it doesn't exist
echo "📁 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Generate secure passwords
echo "🔑 Generating secure passwords..."
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 32)
ALERTMANAGER_WEB_PASSWORD=$(openssl rand -base64 32)

# Create Grafana admin secret
echo "📝 Creating Grafana admin secret..."
kubectl create secret generic grafana-admin-credentials \
  --namespace=monitoring \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create general monitoring secrets
echo "📝 Creating monitoring secrets..."
kubectl create secret generic monitoring-credentials \
  --namespace=monitoring \
  --from-literal=grafana-admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --from-literal=alertmanager-password="$ALERTMANAGER_WEB_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "✅ Monitoring secrets created successfully!"
echo ""
echo "🔐 Generated Credentials:"
echo "========================"
echo "Grafana Admin:"
echo "  - Username: admin"
echo "  - Password: $GRAFANA_ADMIN_PASSWORD"
echo ""
echo "📝 Credentials are stored in Kubernetes secrets:"
echo "  - grafana-admin-credentials (in monitoring namespace)"
echo "  - monitoring-credentials (in monitoring namespace)"
echo ""
echo "🔍 To retrieve passwords later:"
echo "================================"
echo "# Grafana admin password:"
echo "kubectl get secret grafana-admin-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d"
echo ""
echo "# Or from the general secret:"
echo "kubectl get secret monitoring-credentials -n monitoring -o jsonpath='{.data.grafana-admin-password}' | base64 -d"
echo ""
echo "🎯 Next steps:"
echo "=============="
echo "1. Deploy the monitoring stack: ./deploy-monitoring.sh"
echo "2. Access Grafana at http://NODE_IP:30080 with the credentials above"
echo "3. The monitoring stack will now use these secure credentials"

# Save credentials to a secure file (with restricted permissions)
CREDS_FILE="./monitoring-credentials.txt"
cat > "$CREDS_FILE" << EOF
# Monitoring Stack Credentials
# Generated: $(date)
# 
# Grafana Admin:
# Username: admin
# Password: $GRAFANA_ADMIN_PASSWORD
#
# Retrieve from Kubernetes:
# kubectl get secret grafana-admin-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
EOF

chmod 600 "$CREDS_FILE"
echo ""
echo "💾 Credentials also saved to: $CREDS_FILE (with secure permissions)"
echo "🚨 Keep this file secure and consider deleting it after noting the passwords!"
