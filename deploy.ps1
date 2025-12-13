# Load configuration
Get-Content config.env | ForEach-Object {
    if ($_ -match '^([^#][^=]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# Install Dapr on EKS cluster
Write-Host "Installing Dapr..."
dapr init -k

# Apply AWS credentials secret with variable substitution
Write-Host "Creating AWS secret..."
(Get-Content k8s/aws-secret.yaml) -replace '\$\{([^}]+)\}', { param($match) [Environment]::GetEnvironmentVariable($match.Groups[1].Value) } | kubectl apply -f -

# Apply Dapr components with variable substitution
Write-Host "Applying Dapr components..."
(Get-Content dapr-components/pubsub.yaml) -replace '\$\{([^}]+)\}', { param($match) [Environment]::GetEnvironmentVariable($match.Groups[1].Value) } | kubectl apply -f -

# Deploy services with variable substitution
Write-Host "Deploying ProductService..."
(Get-Content k8s/product-service.yaml) -replace '\$\{([^}]+)\}', { param($match) [Environment]::GetEnvironmentVariable($match.Groups[1].Value) } | kubectl apply -f -

Write-Host "Deploying OrderService..."
(Get-Content k8s/order-service.yaml) -replace '\$\{([^}]+)\}', { param($match) [Environment]::GetEnvironmentVariable($match.Groups[1].Value) } | kubectl apply -f -

Write-Host "Deployment complete!"
Write-Host "Check status with: kubectl get pods"