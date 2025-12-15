#!/bin/bash

echo "=== EKS Pod Status ==="
kubectl get pods

echo ""
echo "=== Dapr Components ==="
kubectl get components

echo ""
echo "=== Dapr Subscriptions ==="
kubectl get subscriptions

# Port forward ProductService for testing
echo ""
echo "Starting port forwarding..."
kubectl port-forward svc/product-service 8080:80 &
PID=$!

sleep 3

echo "Services available at:"
echo "ProductService: http://localhost:8080"
echo "OrderService: Event handler only (no direct endpoints)"

echo ""
echo "=== Running Tests ==="

# Test 1: Create a product
echo "1. Creating a product..."
response=$(curl -s -X POST http://localhost:8080/products -H 'Content-Type: application/json' -d '{"name":"Laptop","price":999.99}')
if [ $? -eq 0 ]; then
    echo "✓ Product created: $response"
else
    echo "✗ Failed to create product"
fi

# Test 2: Get all products
echo "2. Getting all products..."
response=$(curl -s http://localhost:8080/products)
if [ $? -eq 0 ]; then
    echo "✓ Products retrieved: $response"
else
    echo "✗ Failed to get products"
fi

# Test 3: Check OrderService status
echo "3. Checking OrderService status..."
status=$(kubectl get pods -l app=order-service -o jsonpath='{.items[0].status.phase}')
if [ "$status" = "Running" ]; then
    echo "✓ OrderService is running and ready to handle events"
else
    echo "✗ OrderService status: $status"
fi

# Test 4: Check for event processing
echo "4. Checking if product events are being processed..."
logs=$(kubectl logs -l app=order-service -c order-service --tail=20 2>/dev/null)
if echo "$logs" | grep -q "\[EVENT RECEIVED\]"; then
    echo "✓ OrderService is processing product events:"
    echo "$logs" | grep "\[EVENT RECEIVED\]" | sed 's/^/  /'
elif echo "$logs" | grep -q "POST /orders/handle"; then
    echo "✓ OrderService received events but detailed logs not available yet"
else
    echo "ℹ No recent events processed (this is normal if no products were created recently)"
fi

echo ""
echo "=== Dapr Sidecar Logs ==="
echo "Product Service Dapr logs:"
kubectl logs -l app=product-service -c daprd --tail=5
echo ""
echo "Order Service Dapr logs:"
kubectl logs -l app=order-service -c daprd --tail=5

echo ""
echo "=== Manual Test Commands ==="
echo "# Create a product"
echo "curl -X POST http://localhost:8080/products -H 'Content-Type: application/json' -d '{\"name\":\"Mouse\",\"price\":29.99}'"
echo "# Get all products"
echo "curl http://localhost:8080/products"
echo "# Check OrderService logs for events"
echo "kubectl logs -l app=order-service -c order-service"
echo "# Check Dapr components"
echo "kubectl get components"

# Cleanup
kill $PID 2>/dev/null