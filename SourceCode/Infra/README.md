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

2. Navigate to Infra directory:
```bash
cd Infra
```

3. Create the EKS cluster (eksctl will auto-create IAM roles):
```bash
eksctl create cluster -f cluster-config.yaml
```

4. Update kubeconfig and verify cluster:
```bash
aws eks update-kubeconfig --region us-east-1 --name introspect-1b-cluster
kubectl config current-context
kubectl get nodes
```

5. If you saw the IRSA warning, update the vpc-cni addon:
```bash
eksctl update addon --name vpc-cni --cluster introspect-1b-cluster --region us-east-1
```

6. Configure default storage class (required for Dapr scheduler):
**Bash/Linux/macOS:**
```bash
kubectl patch storageclass gp2 -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}"
```
**PowerShell:**
```powershell
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Dapr Installation

7. Install Dapr on the cluster:
```bash
dapr init -k
```

8. Verify Dapr installation:
```bash
dapr status -k
```

9. View Dapr pods running in the cluster:
```bash
kubectl get pods -n dapr-system
```

## Troubleshooting

### IRSA/vpc-cni Warning

If you see this warning during cluster creation:
```
IRSA config is set for "vpc-cni" addon, but since OIDC is disabled on the cluster, eksctl cannot configure the requested permissions
```

**Solution:** Update the vpc-cni addon after cluster creation:
```bash
eksctl update addon --name vpc-cni --cluster introspect-1b-cluster --region us-east-1
```

### If Nodes Are Not Created

If `kubectl get nodes` shows no nodes, the nodegroup creation likely failed due to insufficient permissions.

**Required Permission Fix:**
Ensure your IAM user/group has `"ec2:*"` permission. In AWS Console:
1. Go to IAM → User groups → [Your Group]
2. Edit the attached policy
3. Add `"ec2:*"` to the Action list
4. Save the policy

5. After fixing permissions, create nodegroup manually:

**Linux/macOS:**
```bash
eksctl create nodegroup \
  --cluster introspect-1b-cluster \
  --region us-east-1 \
  --name mng-od-4vcpu-4gb \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 5 \
  --node-private-networking
```

**Windows PowerShell:**
```powershell
eksctl create nodegroup `
  --cluster introspect-1b-cluster `
  --region us-east-1 `
  --name mng-od-4vcpu-4gb `
  --node-type t3.medium `
  --nodes 2 `
  --nodes-min 1 `
  --nodes-max 5 `
  --node-private-networking
```

**Note:** Configuring the storage class before Dapr installation prevents dapr-scheduler-server pods from being in pending state.