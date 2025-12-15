#!/bin/bash

# Load configuration
source config.env

# Build Docker images
echo "Building ProductService..."
docker build -t product-service:latest ./ProductService/

echo "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Create ECR repositories if they don't exist
echo "Creating ECR repositories..."
aws ecr create-repository --repository-name product-service --region $AWS_REGION 2>/dev/null || true
aws ecr create-repository --repository-name order-service --region $AWS_REGION 2>/dev/null || true

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Tag for ECR
docker tag product-service:latest $PRODUCT_SERVICE_IMAGE
docker tag order-service:latest $ORDER_SERVICE_IMAGE

# Push to ECR
echo "Pushing images to ECR..."
docker push $PRODUCT_SERVICE_IMAGE
docker push $ORDER_SERVICE_IMAGE

echo "Build and push completed successfully!"