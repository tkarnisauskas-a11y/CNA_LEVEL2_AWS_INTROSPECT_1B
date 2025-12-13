# Configuration Reference

All user-required credentials and configuration values have been centralized in `config.env`. Update this file with your specific values before running any scripts.

## Configuration Variables

| Variable | Description | Used In |
|----------|-------------|---------|
| `AWS_REGION` | AWS region for resources | `dapr-components/pubsub.yaml`, `build.sh`, `build.ps1` |
| `AWS_ACCOUNT_ID` | Your AWS account ID | `config.env` (for ECR_REGISTRY) |
| `ECR_REGISTRY` | ECR registry URL | `build.sh`, `build.ps1` |
| `AWS_ACCESS_KEY_ID_B64` | Base64 encoded AWS access key | `k8s/aws-secret.yaml` |
| `AWS_SECRET_ACCESS_KEY_B64` | Base64 encoded AWS secret key | `k8s/aws-secret.yaml` |
| `AWS_SESSION_TOKEN_B64` | Base64 encoded AWS session token | `k8s/aws-secret.yaml` |
| `PRODUCT_SERVICE_IMAGE` | Product service container image | `k8s/product-service.yaml`, `build.sh`, `build.ps1` |
| `ORDER_SERVICE_IMAGE` | Order service container image | `k8s/order-service.yaml`, `build.sh`, `build.ps1` |

## Setup Instructions

1. **Copy and update config.env**:
   ```bash
   cp config.env config.env.local
   # Edit config.env with your values
   ```

2. **Generate base64 encoded credentials**:
   ```bash
   echo -n "your-access-key" | base64
   echo -n "your-secret-key" | base64
   echo -n "your-session-token" | base64
   ```

3. **Update config.env** with your actual values:
   - Replace `<your-account-id>` with your AWS account ID
   - Replace `<base64-encoded-*>` with your base64 encoded credentials
   - Update `AWS_REGION` if different from us-east-1

## File References

### Scripts that load config.env:
- `build.sh` - Loads config for ECR registry and image tagging
- `build.ps1` - PowerShell version of build script
- `deploy.sh` - Loads config and substitutes variables in YAML files
- `deploy.ps1` - PowerShell version of deploy script

### Files with variable substitution:
- `k8s/aws-secret.yaml` - AWS credentials
- `dapr-components/pubsub.yaml` - AWS region
- `k8s/product-service.yaml` - Container image
- `k8s/order-service.yaml` - Container image

## Security Notes

- Add `config.env` to `.gitignore` to prevent committing credentials
- Consider using AWS IAM roles for EKS instead of access keys
- Use AWS Secrets Manager or Parameter Store for production deployments