#!/bin/bash

# Build Docker images
echo "Building ProductService..."
docker build -t product-service:latest ./ProductService/

echo "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Tag for ECR (replace with your ECR repository URI)
ECR_REGISTRY="<account-id>.dkr.ecr.<region>.amazonaws.com"

docker tag product-service:latest $ECR_REGISTRY/product-service:latest
docker tag order-service:latest $ECR_REGISTRY/order-service:latest

echo "Images built successfully!"
echo "Push to ECR with:"
echo "aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin $ECR_REGISTRY"
echo "docker push $ECR_REGISTRY/product-service:latest"
echo "docker push $ECR_REGISTRY/order-service:latest"