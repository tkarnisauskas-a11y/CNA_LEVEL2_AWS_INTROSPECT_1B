# EKS Microservices with Dapr

This project demonstrates containerized microservices on Amazon EKS with Dapr sidecars for pub/sub messaging using AWS SNS.

## Dapr Concepts Used

- **Pub/Sub API**: For asynchronous messaging between services
- **Components**: AWS SNS/SQS pub/sub component configuration
- **Declarative Subscriptions**: Kubernetes-native subscription configuration
- **Sidecars**: Dapr runtime injected alongside each microservice

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for EKS cluster
- [Docker](https://docs.docker.com/get-docker/) installed and running
  - **Windows**: Ensure Docker Desktop is started before running build scripts
- [Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) installed
- [eksctl](https://eksctl.io/installation/) for EKS cluster management

## Infrastructure Setup

Before deploying the microservices, set up the EKS cluster:

See `Infra/README.md` for EKS cluster setup instructions.

## Configuration

**IMPORTANT**: Before running any scripts, update `config.env` with your AWS credentials and configuration.

See `CONFIG_REFERENCE.md` for detailed setup instructions and credential configuration.

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
# Publish to 'product.new' topic
response = requests.post(
    f"http://localhost:3500/v1.0/publish/product-pubsub/product.new",
    json=product_data
)
```

### Subscribing to Messages (OrderService)

The OrderService uses **declarative subscriptions** via Kubernetes YAML:

```yaml
apiVersion: dapr.io/v2alpha1
kind: Subscription
metadata:
  name: order-subscription
spec:
  pubsubname: product-pubsub
  topic: product.new
  routes:
    default: /orders/handle
  scopes:
  - order-service
```

The app handles incoming CloudEvents:
```python
@app.route('/orders/handle', methods=['POST'])
def handle_order_event():
    body = request.json
    event_id = body.get('id')
    event_type = body.get('type')
    data = body.get('data')
    # Process business logic
    return '', 200
```



## API Endpoints

### ProductService (Port 5000)
- `POST /products` - Create product and publish event to `product.new` topic
- `GET /products` - List all products
- `GET /products/{id}` - Get product by ID
- `GET /health` - Health check

### OrderService (Port 8081)
- `POST /orders/handle` - Handle product events (Dapr subscription endpoint)

**Note**: OrderService is now a minimal event handler focused solely on processing product events.

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

# Describe subscription details
kubectl describe subscription order-subscription
```

## Expected Behavior

1. **Create a product** via ProductService → Product event published to `product.new` topic on AWS SNS
2. **OrderService receives** the product event automatically via declarative Dapr subscription
3. **OrderService processes** the event and logs the CloudEvent data (id, type, data)
4. **View logs** to see the pub/sub message flow and event processing

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete EKS cluster
eksctl delete cluster --name introspect-1b-cluster --region us-east-1
```