# EKS Microservices with Dapr

This project demonstrates containerized microservices on Amazon EKS with Dapr sidecars for pub/sub messaging using AWS SNS/SQS.

## Architecture

- **ProductService**: Creates products, stores in JSON files, publishes events
- **OrderService**: Creates orders, subscribes to product events, calls ProductService via Dapr
- **Dapr**: Handles service-to-service communication and pub/sub messaging
- **AWS SNS/SQS**: Message broker for pub/sub patterns

## Prerequisites

- AWS CLI configured
- kubectl configured for EKS cluster
- Docker installed
- Dapr CLI installed

## Quick Start

### Linux/macOS
1. **Build images**:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

2. **Deploy to EKS**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Test services**:
   ```bash
   chmod +x test-services.sh
   ./test-services.sh
   ```

### Windows PowerShell
1. **Build images**:
   ```powershell
   .\build.ps1
   ```

2. **Deploy to EKS**:
   ```powershell
   .\deploy.ps1
   ```

3. **Test services**:
   ```powershell
   .\test-services.ps1
   ```

## API Endpoints

### ProductService (Port 8080)
- `POST /products` - Create product
- `GET /products` - List products
- `GET /products/{id}` - Get product by ID

### OrderService (Port 8081)
- `POST /orders` - Create order
- `GET /orders` - List orders

## Configuration

Update `k8s/aws-secret.yaml` with base64-encoded AWS credentials:
```bash
echo -n "your-access-key" | base64
echo -n "your-secret-key" | base64
```

## Monitoring

View Dapr logs:
```bash
kubectl logs -l app=product-service -c daprd
kubectl logs -l app=order-service -c daprd
```