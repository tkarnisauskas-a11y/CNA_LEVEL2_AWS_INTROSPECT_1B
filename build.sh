#!/bin/bash

# Load configuration
source config.env

# Build Docker images
echo "Building ProductService..."
docker build -t product-service:latest ./ProductService/

echo "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Tag for ECR
docker tag product-service:latest $PRODUCT_SERVICE_IMAGE
docker tag order-service:latest $ORDER_SERVICE_IMAGE

echo "Images built successfully!"
echo "Push to ECR with:"
echo "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY"
echo "docker push $PRODUCT_SERVICE_IMAGE"
echo "docker push $ORDER_SERVICE_IMAGE"