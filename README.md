# EKS RBAC Configuration

## Fix AWS Console Access Error

If you get "nodes is forbidden" error in AWS Console, apply RBAC permissions:

```bash
# Apply RBAC configuration
kubectl apply -f Infra/rbac-config.yaml

# Verify the role was created
kubectl get clusterrole console-viewer
kubectl get clusterrolebinding console-viewer-binding
```

## Update Cluster Identity Mapping

Ensure your cluster-config.yaml includes the federated user mapping with the console-viewer group.