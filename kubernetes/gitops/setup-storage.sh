#!/bin/bash

# Setup storage for kubeadm cluster
# This script installs local-path-provisioner for dynamic storage

set -e

echo "🗄️  Setting up storage for Kubernetes cluster..."

# Check if a default storage class already exists
if kubectl get storageclass | grep -q "(default)"; then
    DEFAULT_SC=$(kubectl get storageclass | grep "(default)" | awk '{print $1}')
    echo "✅ Default storage class found: $DEFAULT_SC"
    echo "You can use this storage class or continue to install local-path-provisioner"
    read -p "Install local-path-provisioner anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing storage class: $DEFAULT_SC"
        exit 0
    fi
fi

echo "📦 Installing local-path-provisioner..."

# Install local-path-provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.28/deploy/local-path-storage.yaml

# Wait for the provisioner to be ready
echo "⏳ Waiting for local-path-provisioner to be ready..."
kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n local-path-storage --timeout=300s

# Set as default storage class
echo "🎯 Setting local-path as default storage class..."
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "✅ Storage setup complete!"
echo ""
echo "📊 Available storage classes:"
kubectl get storageclass
