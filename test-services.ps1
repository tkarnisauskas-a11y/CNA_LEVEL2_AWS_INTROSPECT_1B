# Port forward services for testing
Start-Job -ScriptBlock { kubectl port-forward svc/product-service 8080:80 }
Start-Job -ScriptBlock { kubectl port-forward svc/order-service 8081:80 }

Write-Host "Services available at:"
Write-Host "ProductService: http://localhost:8080"
Write-Host "OrderService: http://localhost:8081"

Write-Host ""
Write-Host "Test commands:"
Write-Host "# Create a product"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8080/products' -Method Post -ContentType 'application/json' -Body '{\"name\":\"Laptop\",\"price\":999.99}'"
Write-Host ""
Write-Host "# Get all products"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8080/products'"
Write-Host ""
Write-Host "# Create an order"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8081/orders' -Method Post -ContentType 'application/json' -Body '{\"product_id\":1,\"quantity\":2}'"
Write-Host ""
Write-Host "# Get all orders"
Write-Host "Invoke-RestMethod -Uri 'http://localhost:8081/orders'"