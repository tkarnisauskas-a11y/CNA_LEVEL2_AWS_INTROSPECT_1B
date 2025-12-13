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

# Apply AWS credentials secret with variable substitution
Write-Host "Creating AWS secret..."
$content = Get-Content k8s/aws-secret.yaml -Raw
$content = $content -replace '\$\{AWS_ACCESS_KEY_ID\}', $env:AWS_ACCESS_KEY_ID
$content = $content -replace '\$\{AWS_SECRET_ACCESS_KEY\}', $env:AWS_SECRET_ACCESS_KEY
$content = $content -replace '\$\{AWS_SESSION_TOKEN\}', $env:AWS_SESSION_TOKEN
$content | kubectl apply -f -

# Apply Dapr components with variable substitution
Write-Host "Applying Dapr components..."
kubectl apply -f dapr-components/dapr-config.yaml
$content = Get-Content dapr-components/pubsub.yaml -Raw
$content = $content -replace '\$\{AWS_REGION\}', $env:AWS_REGION
$content | kubectl apply -f -

# Deploy services with variable substitution
Write-Host "Deploying ProductService..."
$content = Get-Content k8s/product-service.yaml -Raw
$content = $content -replace '\$\{AWS_ACCOUNT_ID\}', $env:AWS_ACCOUNT_ID
$content = $content -replace '\$\{AWS_REGION\}', $env:AWS_REGION
$content = $content -replace '\$\{PRODUCT_SERVICE_IMAGE\}', $env:PRODUCT_SERVICE_IMAGE
$content | kubectl apply -f -

Write-Host "Deploying OrderService..."
$content = Get-Content k8s/order-service.yaml -Raw
$content = $content -replace '\$\{AWS_ACCOUNT_ID\}', $env:AWS_ACCOUNT_ID
$content = $content -replace '\$\{AWS_REGION\}', $env:AWS_REGION
$content = $content -replace '\$\{ORDER_SERVICE_IMAGE\}', $env:ORDER_SERVICE_IMAGE
$content | kubectl apply -f -

# No subscriptions needed - OrderService uses direct service invocation

Write-Host "Deployment complete!"
Write-Host "Check status with: kubectl get pods"