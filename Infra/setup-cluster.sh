#!/bin/bash

# EKS Cluster Setup Script
set -e

echo "Creating EKS cluster..."
eksctl create cluster -f cluster-config.yaml

echo "Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name introspect-1b-cluster

echo "Verifying cluster..."
kubectl get nodes

echo "Configuring default storage class..."
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Installing Dapr..."
dapr init -k --dev

echo "Verifying Dapr installation..."
kubectl get pods -n dapr-system

echo "Cluster setup complete!"