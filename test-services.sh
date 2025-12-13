#!/bin/bash

# Port forward services for testing
kubectl port-forward svc/product-service 8080:80 &
kubectl port-forward svc/order-service 8081:80 &

echo "Services available at:"
echo "ProductService: http://localhost:8080"
echo "OrderService: http://localhost:8081"

echo ""
echo "Test commands:"
echo "# Create a product"
echo "curl -X POST http://localhost:8080/products -H 'Content-Type: application/json' -d '{\"name\":\"Laptop\",\"price\":999.99}'"
echo ""
echo "# Get all products"
echo "curl http://localhost:8080/products"
echo ""
echo "# Create an order"
echo "curl -X POST http://localhost:8081/orders -H 'Content-Type: application/json' -d '{\"product_id\":1,\"quantity\":2}'"
echo ""
echo "# Get all orders"
echo "curl http://localhost:8081/orders"