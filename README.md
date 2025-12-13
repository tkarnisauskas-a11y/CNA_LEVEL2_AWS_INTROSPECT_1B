# EKS Microservices with Dapr

This project demonstrates containerized microservices on Amazon EKS with Dapr sidecars for pub/sub messaging using AWS SNS.

## Overview

This sample shows how to create a publisher microservice and a subscriber microservice, leveraging Dapr's pub/sub API. This sample uses AWS SNS as the message broker.

## Architecture

- **ProductService (Publisher)**: Creates products, stores in JSON files, publishes events to `product-events` topic
- **OrderService (Subscriber)**: Creates orders, subscribes to `product-events` topic, calls ProductService via Dapr service invocation
- **Dapr**: Handles service-to-service communication and pub/sub messaging with automatic retries and dead letter queues
- **AWS SNS**: Message broker for publishing product events with built-in durability and scalability
- **Kafka**: Message broker for order events (OrderService to OrderService)

## Dapr Concepts Used

- **Pub/Sub API**: For asynchronous messaging between services
- **Service Invocation API**: For synchronous service-to-service calls
- **Components**: AWS SNS/SQS pub/sub component configuration
- **Sidecars**: Dapr runtime injected alongside each microservice

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for EKS cluster
- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) installed
- [eksctl](https://eksctl.io/installation/) for EKS cluster management

## Infrastructure Setup

Before deploying the microservices, set up the EKS cluster:

See `Infra/README.md` for EKS cluster setup instructions.

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

## How it Works

### Publishing Messages (ProductService)

The ProductService publishes messages using Dapr's pub/sub API:

```python
# Publish to 'product-events' topic
response = requests.post(
    f"http://localhost:3500/v1.0/publish/pubsub/product-events",
    json=product_data
)
```

### Subscribing to Messages (OrderService)

The OrderService subscribes to messages by:

1. **Declaring subscriptions** via `/dapr/subscribe` endpoint:
```python
@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    return [{
        "pubsubname": "pubsub",
        "topic": "product-events",
        "route": "/product-events"
    }]
```

2. **Handling incoming messages** via the subscription route:
```python
@app.route('/product-events', methods=['POST'])
def handle_product_event():
    event_data = request.json
    # Process the product event
    return '', 200
```

### Service-to-Service Communication

Services communicate via Dapr's service invocation API:

```python
# OrderService calling ProductService
response = requests.get(
    f"http://localhost:3500/v1.0/invoke/product-service/method/products/{product_id}"
)
```

## API Endpoints

### ProductService (Port 8080)
- `POST /products` - Create product and publish event
- `GET /products` - List all products
- `GET /products/{id}` - Get product by ID

### OrderService (Port 8081)
- `POST /orders` - Create order (validates product via service invocation)
- `GET /orders` - List all orders
- `POST /product-events` - Handle product events (Dapr subscription)
- `GET /dapr/subscribe` - Dapr subscription configuration

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

## Monitoring and Debugging

### View Application Logs
```bash
# ProductService logs
kubectl logs -l app=product-service -c product-service

# OrderService logs
kubectl logs -l app=order-service -c order-service
```

### View Dapr Sidecar Logs
```bash
# ProductService Dapr sidecar
kubectl logs -l app=product-service -c daprd

# OrderService Dapr sidecar
kubectl logs -l app=order-service -c daprd
```

### Check Dapr Components
```bash
# List Dapr components
kubectl get components

# Describe pub/sub component
kubectl describe component pubsub
```

### Verify Subscriptions
```bash
# Check if subscriptions are registered
kubectl get subscriptions
```

## Expected Behavior

1. **Create a product** via ProductService → Product event published to SNS
2. **OrderService receives** the product event automatically via Dapr subscription
3. **Create an order** via OrderService → Validates product exists via service invocation
4. **View logs** to see the pub/sub and service invocation flow

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete EKS cluster
eksctl delete cluster --name introspect-1b-cluster --region us-east-1
```