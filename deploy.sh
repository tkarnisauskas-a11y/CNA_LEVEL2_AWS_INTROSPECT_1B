#!/bin/bash

# Install Dapr on EKS cluster
echo "Installing Dapr..."
dapr init -k

# Apply AWS credentials secret
echo "Creating AWS secret..."
kubectl apply -f k8s/aws-secret.yaml

# Apply Dapr components
echo "Applying Dapr components..."
kubectl apply -f dapr-components/

# Deploy services
echo "Deploying ProductService..."
kubectl apply -f k8s/product-service.yaml

echo "Deploying OrderService..."
kubectl apply -f k8s/order-service.yaml

echo "Deployment complete!"
echo "Check status with: kubectl get pods"