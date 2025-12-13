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

**IMPORTANT**: Before running any scripts, update `config.env` with your AWS credentials and configuration:

1. Edit `config.env` and replace placeholder values:
   - `AWS_ACCOUNT_ID`: Your AWS account ID
   - `AWS_REGION`: Your preferred AWS region
   - `AWS_ACCESS_KEY_ID_B64`: Base64 encoded access key
   - `AWS_SECRET_ACCESS_KEY_B64`: Base64 encoded secret key
   - `AWS_SESSION_TOKEN_B64`: Base64 encoded session token

2. Generate base64 credentials:
```bash
echo -n "your-access-key" | base64
echo -n "your-secret-key" | base64
echo -n "your-session-token" | base64
```

See `CONFIG_REFERENCE.md` for detailed configuration information.

## Monitoring

View Dapr logs:
```bash
kubectl logs -l app=product-service -c daprd
kubectl logs -l app=order-service -c daprd
```