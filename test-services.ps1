# Check pod status and Dapr sidecars
Write-Host "=== EKS Pod Status ==="
kubectl get pods

Write-Host ""
Write-Host "=== Dapr Sidecar Status ==="
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}'

Write-Host ""
Write-Host "=== Dapr Components ==="
kubectl get components

# Port forward services for testing
Write-Host ""
Write-Host "Starting port forwarding..."
Start-Job -ScriptBlock { kubectl port-forward svc/product-service 8080:80 }
Start-Job -ScriptBlock { kubectl port-forward svc/order-service 8081:80 }

Start-Sleep 3

Write-Host "Services available at:"
Write-Host "ProductService: http://localhost:8080"
Write-Host "OrderService: http://localhost:8081"

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

# Test 3: Create an order (tests Dapr service-to-service call)
Write-Host "3. Creating an order (tests Dapr sidecar communication)..."
try {
    $order = Invoke-RestMethod -Uri 'http://localhost:8081/orders' -Method Post -ContentType 'application/json' -Body '{"product_id":1,"quantity":2}'
    Write-Host "✓ Order created: $($order | ConvertTo-Json)"
} catch {
    Write-Host "✗ Failed to create order: $($_.Exception.Message)"
}

# Test 4: Get all orders
Write-Host "4. Getting all orders..."
try {
    $orders = Invoke-RestMethod -Uri 'http://localhost:8081/orders'
    Write-Host "✓ Orders retrieved: $($orders | ConvertTo-Json)"
} catch {
    Write-Host "✗ Failed to get orders: $($_.Exception.Message)"
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
Write-Host "# Create an order"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8081/orders' -Method Post -ContentType 'application/json' -Body '{\"product_id\":2,\"quantity\":1}'"
Write-Host "# Get all orders"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8081/orders'"