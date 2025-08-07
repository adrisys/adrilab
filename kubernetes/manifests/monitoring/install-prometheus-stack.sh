#!/bin/bash

# Prometheus and Grafana Installation Script
# This script installs the Prometheus Operator stack with Grafana dashboard

set -e

echo "🚀 Installing Prometheus and Grafana monitoring stack..."

# Add Prometheus community Helm repository
echo "📦 Adding Prometheus community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Create monitoring namespace
echo "📁 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install kube-prometheus-stack (includes Prometheus, Grafana, Alertmanager, and various exporters)
echo "⚙️ Installing kube-prometheus-stack..."
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=local-path \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.storageClassName=local-path \
  --set grafana.persistence.size=5Gi \
  --set grafana.adminPassword=admin123 \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName=local-path \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=5Gi \
  --set prometheus.prometheusSpec.retention=15d \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30000 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30001 \
  --wait

echo "✅ Prometheus stack installed successfully!"

# Display access information
echo ""
echo "🔐 Access Information:"
echo "===================="
echo "Grafana Dashboard:"
echo "  - URL: http://your-node-ip:30000"
echo "  - Username: admin"
echo "  - Password: admin123"
echo ""
echo "Prometheus UI:"
echo "  - URL: http://your-node-ip:30001"
echo ""
echo "Alertmanager UI:"
echo "  - URL: http://your-node-ip:30002 (if exposed)"
echo ""

# Get node IPs for reference
echo "📍 Your node IPs:"
kubectl get nodes -o wide | awk '{print $1"\t"$7}' | column -t

echo ""
echo "🎯 Quick commands:"
echo "  - Check pods: kubectl get pods -n monitoring"
echo "  - Check services: kubectl get svc -n monitoring"
echo "  - Port-forward Grafana: kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80"
echo "  - Port-forward Prometheus: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
