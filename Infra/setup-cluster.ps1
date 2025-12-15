# EKS Cluster Setup Script for Windows PowerShell

Write-Host "Creating EKS cluster..." -ForegroundColor Green
eksctl create cluster -f cluster-config.yaml

Write-Host "Updating kubeconfig..." -ForegroundColor Green
aws eks update-kubeconfig --region us-east-1 --name introspect-1b-cluster

Write-Host "Verifying cluster..." -ForegroundColor Green
kubectl get nodes

Write-Host "Configuring default storage class..." -ForegroundColor Green
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

Write-Host "Installing Dapr..." -ForegroundColor Green
dapr init -k --dev

Write-Host "Verifying Dapr installation..." -ForegroundColor Green
kubectl get pods -n dapr-system

Write-Host "Cluster setup complete!" -ForegroundColor Green