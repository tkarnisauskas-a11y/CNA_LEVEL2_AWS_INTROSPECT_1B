# EKS Cluster Setup

## Prerequisites
- AWS CLI installed
- eksctl installed
- kubectl installed
- Dapr CLI installed

## Setup Instructions

1. Configure AWS credentials:
```bash
aws configure
```

2. Create the EKS cluster:
```bash
eksctl create cluster -f cluster-config.yaml
```

3. Verify cluster context and nodes (created by managedNodeGroups):
```bash
kubectl config current-context
kubectl get nodes
```

## Dapr Configuration

1. Find your EKS cluster security group ID:
```bash
aws ec2 describe-security-groups --filters "Name=group-name,Values=*introspect-1b-cluster*" --query "SecurityGroups[*].GroupId" --output text
```

2. Update security group for Dapr sidecar communication (replace [your_security_group] with the ID from step 4):
```bash
aws ec2 authorize-security-group-ingress --region us-east-1 \
--group-id [your_security_group] \
--protocol tcp \
--port 4000 \
--source-group [your_security_group]
```

3. Verify cluster exists and is running:
```bash
aws eks describe-cluster --region us-east-1 --name introspect-1b-cluster
```

4. If cluster exists, update kubeconfig:
```bash
aws eks update-kubeconfig --region us-east-1 --name introspect-1b-cluster
```

5. Install Dapr on the cluster:
```bash
dapr init -k
```

**What `dapr init -k` does:**
- `-k` flag specifies Kubernetes mode (vs self-hosted mode)
- Downloads and installs Dapr control plane components:
  - **dapr-operator**: Manages Dapr components and configurations
  - **dapr-sidecar-injector**: Automatically injects Dapr sidecar containers
  - **dapr-placement**: Manages actor placement across cluster nodes
  - **dapr-sentry**: Provides certificate authority for mTLS between services
- Creates `dapr-system` namespace
- Installs Custom Resource Definitions (CRDs) for Dapr components
- Sets up RBAC permissions
- Configures default Dapr configuration

6. Verify Dapr installation:
```bash
dapr status -k
```

7. View Dapr pods running in the cluster:
```bash
kubectl get pods -n dapr-system
```