#!/bin/bash

# Load configuration
source config.env

# Install Dapr on EKS cluster
echo "Installing Dapr..."
dapr init -k

# Apply AWS credentials secret with variable substitution
echo "Creating AWS secret..."
envsubst < k8s/aws-secret.yaml | kubectl apply -f -

# Apply Dapr components with variable substitution
echo "Applying Dapr components..."
envsubst < dapr-components/pubsub.yaml | kubectl apply -f -

# Deploy services with variable substitution
echo "Deploying ProductService..."
envsubst < k8s/product-service.yaml | kubectl apply -f -

echo "Deploying OrderService..."
envsubst < k8s/order-service.yaml | kubectl apply -f -

echo "Deployment complete!"
echo "Check status with: kubectl get pods"