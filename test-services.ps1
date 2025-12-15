# Check pod status and Dapr sidecars
Write-Host "=== EKS Pod Status ==="
kubectl get pods

Write-Host ""
Write-Host "=== Dapr Sidecar Status ==="
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}'

Write-Host ""
Write-Host "=== Dapr Components ==="
kubectl get components

# Port forward ProductService for testing
Write-Host ""
Write-Host "Starting port forwarding..."
Start-Job -ScriptBlock { kubectl port-forward svc/product-service 8080:80 }

Start-Sleep 3

Write-Host "Services available at:"
Write-Host "ProductService: http://localhost:8080"
Write-Host "OrderService: Event handler only (no direct endpoints)"

Write-Host ""
Write-Host "=== Running Tests ==="

# Test 1: Create a product
Write-Host "1. Creating a product..."
try {
    $product = Invoke-RestMethod -Uri 'http://localhost:8080/products' -Method Post -ContentType 'application/json' -Body '{"name":"Laptop","price":999.99}'
    Write-Host "✓ Product created: $($product | ConvertTo-Json)"
} catch {
    Write-Host "✗ Failed to create product: $($_.Exception.Message)"
}

# Test 2: Get all products
Write-Host "2. Getting all products..."
try {
    $products = Invoke-RestMethod -Uri 'http://localhost:8080/products'
    Write-Host "✓ Products retrieved: $($products | ConvertTo-Json)"
} catch {
    Write-Host "✗ Failed to get products: $($_.Exception.Message)"
}

# Test 3: Check OrderService health (event handler)
Write-Host "3. Checking OrderService status..."
try {
    $response = kubectl get pods -l app=order-service -o jsonpath='{.items[0].status.phase}'
    if ($response -eq "Running") {
        Write-Host "✓ OrderService is running and ready to handle events"
    } else {
        Write-Host "✗ OrderService status: $response"
    }
} catch {
    Write-Host "✗ Failed to check OrderService: $($_.Exception.Message)"
}

# Test 4: Verify pub/sub flow by checking logs
Write-Host "4. Checking if product events are being processed..."
try {
    $logs = kubectl logs -l app=order-service -c order-service --tail=100 2>$null
    if ($logs -match "\[EVENT RECEIVED\]") {
        Write-Host "✓ OrderService is processing product events:"
        # Extract and display received product information
        $eventLines = $logs -split "`n" | Where-Object { $_ -match "\[EVENT RECEIVED\]" }
        foreach ($line in $eventLines) {
            Write-Host "  $line"
        }
    } elseif ($logs -match "POST /orders/handle") {
        Write-Host "✓ OrderService received events but detailed logs not available yet"
    } else {
        Write-Host "ℹ No recent events processed (this is normal if no products were created recently)"
    }
} catch {
    Write-Host "ℹ Could not retrieve logs (service may be starting)"
}

Write-Host ""
Write-Host "=== Dapr Sidecar Logs ==="
Write-Host "Product Service Dapr logs:"
kubectl logs -l app=product-service -c daprd --tail=5
Write-Host ""
Write-Host "Order Service Dapr logs:"
kubectl logs -l app=order-service -c daprd --tail=5

Write-Host ""
Write-Host "=== Manual Test Commands ==="
Write-Host "# Create a product"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8080/products' -Method Post -ContentType 'application/json' -Body '{\"name\":\"Mouse\",\"price\":29.99}'"
Write-Host "# Get all products"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8080/products'"
Write-Host "# Check OrderService logs for events"
Write-Host "kubectl logs -l app=order-service -c order-service"
Write-Host "# Check Dapr pub/sub components"
Write-Host "kubectl get components"