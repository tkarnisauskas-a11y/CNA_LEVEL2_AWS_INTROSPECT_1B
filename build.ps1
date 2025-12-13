# Load configuration
Get-Content config.env | ForEach-Object {
    if ($_ -match '^([^#][^=]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# Build Docker images
Write-Host "Building ProductService..."
docker build -t product-service:latest ./ProductService/

Write-Host "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Tag for ECR
docker tag product-service:latest $env:PRODUCT_SERVICE_IMAGE
docker tag order-service:latest $env:ORDER_SERVICE_IMAGE

Write-Host "Images built successfully!"
Write-Host "Push to ECR with:"
Write-Host "aws ecr get-login-password --region $env:AWS_REGION | docker login --username AWS --password-stdin $env:ECR_REGISTRY"
Write-Host "docker push $env:PRODUCT_SERVICE_IMAGE"
Write-Host "docker push $env:ORDER_SERVICE_IMAGE"