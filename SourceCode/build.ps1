# Get AWS Account ID dynamically
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
[Environment]::SetEnvironmentVariable('AWS_ACCOUNT_ID', $AWS_ACCOUNT_ID)

# Load configuration
Get-Content config.env | ForEach-Object {
    if ($_ -match '^([^#][^=]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# Set ECR registry with dynamic account ID
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$env:AWS_REGION.amazonaws.com"
[Environment]::SetEnvironmentVariable('ECR_REGISTRY', $ECR_REGISTRY)
[Environment]::SetEnvironmentVariable('PRODUCT_SERVICE_IMAGE', "$ECR_REGISTRY/product-service:latest")
[Environment]::SetEnvironmentVariable('ORDER_SERVICE_IMAGE', "$ECR_REGISTRY/order-service:latest")

# Build Docker images
Write-Host "Building ProductService..."
docker build -t product-service:latest ./ProductService/

Write-Host "Building OrderService..."
docker build -t order-service:latest ./OrderService/

# Create ECR repositories if they don't exist
Write-Host "Creating ECR repositories..."
aws ecr create-repository --repository-name product-service --region $env:AWS_REGION 2>$null
aws ecr create-repository --repository-name order-service --region $env:AWS_REGION 2>$null

# Login to ECR
Write-Host "Logging into ECR..."
aws ecr get-login-password --region $env:AWS_REGION | docker login --username AWS --password-stdin $env:ECR_REGISTRY

# Tag for ECR
docker tag product-service:latest "$env:PRODUCT_SERVICE_IMAGE"
docker tag order-service:latest "$env:ORDER_SERVICE_IMAGE"

# Push to ECR
Write-Host "Pushing images to ECR..."
docker push "$env:PRODUCT_SERVICE_IMAGE"
docker push "$env:ORDER_SERVICE_IMAGE"

Write-Host "Build and push completed successfully!"