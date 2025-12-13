# Install Dapr on EKS cluster
Write-Host "Installing Dapr..."
dapr init -k

# Apply AWS credentials secret
Write-Host "Creating AWS secret..."
kubectl apply -f k8s/aws-secret.yaml

# Apply Dapr components
Write-Host "Applying Dapr components..."
kubectl apply -f dapr-components/

# Deploy services
Write-Host "Deploying ProductService..."
kubectl apply -f k8s/product-service.yaml

Write-Host "Deploying OrderService..."
kubectl apply -f k8s/order-service.yaml

Write-Host "Deployment complete!"
Write-Host "Check status with: kubectl get pods"