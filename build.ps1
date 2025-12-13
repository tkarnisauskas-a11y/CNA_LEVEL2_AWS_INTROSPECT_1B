# Build Docker images
Write-Host "Building ProductService..."
docker build -t product-service:latest ./ProductService/

Write-Host "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Tag for ECR (replace with your ECR repository URI)
$ECR_REGISTRY = "<account-id>.dkr.ecr.<region>.amazonaws.com"

docker tag product-service:latest "$ECR_REGISTRY/product-service:latest"
docker tag order-service:latest "$ECR_REGISTRY/order-service:latest"

Write-Host "Images built successfully!"
Write-Host "Push to ECR with:"
Write-Host "aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin $ECR_REGISTRY"
Write-Host "docker push $ECR_REGISTRY/product-service:latest"
Write-Host "docker push $ECR_REGISTRY/order-service:latest"