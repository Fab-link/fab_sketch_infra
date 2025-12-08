# FabSketch Infrastructure

Terraform configuration for deploying FabSketch to AWS.

## 🏗️ Architecture

```
Internet → ALB → ECS Fargate → RDS PostgreSQL
                    ↓
                S3 (Media Files)
```

## 📋 Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Docker Desktop

## 🚀 Quick Deploy

1. **Setup variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy everything**
   ```bash
   ./deploy.sh
   ```

## 🔧 Manual Deployment

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Plan deployment**
   ```bash
   terraform plan
   ```

3. **Apply infrastructure**
   ```bash
   terraform apply
   ```

4. **Build and push Docker image**
   ```bash
   # Get ECR URL
   ECR_URL=$(terraform output -raw ecr_repository_url)
   
   # Build and push (AMD64 platform for ECS Fargate)
   cd ../fab_sketch_backend
   aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_URL
   docker buildx build --platform linux/amd64 -t fab-sketch-app .
   docker tag fab-sketch-app:latest $ECR_URL:latest
   docker push $ECR_URL:latest
   
   # Force ECS deployment
   aws ecs update-service --cluster fab-sketch-cluster --service fab-sketch-service --force-new-deployment --region ap-northeast-2
   ```

## 📊 Resources Created

- **VPC**: Custom VPC with public/private subnets
- **ECS**: Fargate cluster with auto-scaling
- **RDS**: PostgreSQL 14.20 (t3.micro)
- **ALB**: Application Load Balancer
- **S3**: Media files storage
- **ECR**: Docker image repository
- **IAM**: Roles and policies
- **SSM**: Secure parameter store

## 🌐 Endpoints

After deployment:
- **API**: `http://<alb-dns>/api/`
- **Admin**: `http://<alb-dns>/admin/`
- **Health**: `http://<alb-dns>/health/`

## ⚠️ Demo Configuration Notes

### Public Subnet Deployment
For demo purposes, ECS tasks are deployed in **public subnets** with public IPs assigned. This is **NOT recommended for production**.

**Why this configuration:**
- Private subnets require NAT Gateway ($45/month) or VPC Endpoints ($7-10/month)
- Demo environment prioritizes cost over security
- Allows ECS tasks to access SSM Parameter Store and ECR directly

**Production recommendations:**
1. Move ECS tasks to private subnets
2. Add NAT Gateway for internet access
3. Use VPC Endpoints for AWS services
4. Implement proper security groups

### Docker Platform Compatibility
ECS Fargate requires **linux/amd64** platform. Build commands use:
```bash
docker buildx build --platform linux/amd64 -t fab-sketch-app .
```

## 💰 Cost Estimation

**Monthly cost (~$15-25)**:
- RDS t3.micro: ~$12
- ECS Fargate: ~$5-10
- ALB: ~$3
- S3: ~$1

**Additional costs for production:**
- NAT Gateway: +$45/month
- VPC Endpoints: +$7-10/month

## 🔄 Updates

To update the application:
```bash
# Rebuild and push image
cd fab_sketch_backend
ECR_URL=$(terraform output -raw -chdir=../fab_sketch_infra ecr_repository_url)
docker buildx build --platform linux/amd64 -t fab-sketch-app .
docker tag fab-sketch-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Force ECS service update
aws ecs update-service --cluster fab-sketch-cluster --service fab-sketch-service --force-new-deployment --region ap-northeast-2
```

## 🐛 Troubleshooting

### Common Issues

**1. 503 Service Unavailable**
- ECS task is not running or failing health checks
- Check: `aws ecs describe-services --cluster fab-sketch-cluster --services fab-sketch-service`

**2. 504 Gateway Timeout**
- ECS task is starting but not responding to health checks
- Check logs: `aws logs get-log-events --log-group-name "/ecs/fab-sketch"`

**3. Platform Architecture Mismatch**
- Error: "Manifest does not contain descriptor matching platform 'linux/amd64'"
- Solution: Use `--platform linux/amd64` when building Docker images

**4. SSM Parameter Store Access Issues**
- Error: "unable to retrieve secrets from ssm"
- Cause: ECS tasks in private subnets without NAT Gateway
- Solution: Use public subnets (demo) or add NAT Gateway (production)

### Deployment Status Check
```bash
# Check ECS service status
aws ecs describe-services --cluster fab-sketch-cluster --services fab-sketch-service --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'

# Check recent events
aws ecs describe-services --cluster fab-sketch-cluster --services fab-sketch-service --query 'services[0].events[0:3]'

# Check task status
aws ecs list-tasks --cluster fab-sketch-cluster --service-name fab-sketch-service
```

## 🗑️ Cleanup

```bash
terraform destroy
```

## 📱 Flutter Integration

Use the ALB DNS name as your API base URL in Flutter:
```dart
const String API_BASE_URL = 'http://<alb-dns>/api/';
```

## 🔐 Security Considerations

**Current demo setup:**
- ✅ RDS in private subnets
- ✅ Security groups properly configured
- ⚠️ ECS tasks in public subnets (demo only)
- ✅ Secrets stored in SSM Parameter Store
- ✅ IAM roles with minimal permissions

**Production improvements needed:**
- Move ECS to private subnets
- Add WAF for ALB
- Enable VPC Flow Logs
- Implement proper monitoring and alerting
