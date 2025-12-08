# Infrastructure Development Guide

## Current AWS Resources

### Active Infrastructure
- **ECS Cluster**: fab-sketch-cluster
- **ECS Service**: fab-sketch-service
- **ALB**: fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com
- **RDS**: fab-sketch-db.chyooau22dfx.ap-northeast-2.rds.amazonaws.com
- **ECR**: 377449795629.dkr.ecr.ap-northeast-2.amazonaws.com/fab-sketch-app

### Setup for Team Members

1. **AWS CLI Setup**
```bash
aws configure --profile fablink
# Use provided AWS credentials
```

2. **Terraform Setup**
```bash
git clone https://github.com/Fab-link/fab_sketch_infra.git
cd fab_sketch_infra
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with actual values
```

3. **Initialize Terraform**
```bash
terraform init
terraform plan
# DO NOT run terraform apply without team discussion
```

## Deployment Process

### Backend Deployment
```bash
# 1. Build and push image
cd ../fab_sketch_backend
docker buildx build --platform linux/amd64 -t 377449795629.dkr.ecr.ap-northeast-2.amazonaws.com/fab-sketch-app:latest --push .

# 2. Update ECS service
aws ecs update-service --cluster fab-sketch-cluster --service fab-sketch-service --force-new-deployment --profile fablink
```

### Infrastructure Changes
1. Create feature branch
2. Make Terraform changes
3. Run `terraform plan` and share output
4. Get team approval before `terraform apply`

## Monitoring & Debugging

### ECS Service Status
```bash
aws ecs describe-services --cluster fab-sketch-cluster --services fab-sketch-service --profile fablink
```

### Application Logs
```bash
aws logs get-log-events --log-group-name /ecs/fab-sketch --log-stream-name ecs/app/TASK_ID --profile fablink
```

### Database Access
```bash
# Connect via bastion host (if needed)
# RDS endpoint: fab-sketch-db.chyooau22dfx.ap-northeast-2.rds.amazonaws.com
```

## Environment Variables (SSM Parameters)
- `/fab-sketch/SECRET_KEY` - Django secret key
- `/fab-sketch/DB_PASSWORD` - Database password

## Important Notes
- **DO NOT** commit `terraform.tfvars` or `.env` files
- Always test infrastructure changes in development first
- Coordinate deployments with team members
- Keep AWS costs in mind when creating resources
