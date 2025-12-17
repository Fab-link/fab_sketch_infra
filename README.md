# FabSketch Infrastructure

Terraform configuration for deploying FabSketch to AWS.

## 🏗️ Current Architecture

```
Internet → ALB → EC2 (Django) → RDS PostgreSQL
                    ↓
                S3 (Media Files)
                    ↓
                Lambda (AI Generation)
```

## 📊 Current Resources

### Compute
- **EC2 Instance**: `i-0241eb14f5097a359` (t3.medium)
- **ALB**: `fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com`
- **Lambda**: `fabsketch-gen` (AI image generation)

### Storage & Database
- **RDS**: `fab-sketch-db.chyooau22dfx.ap-northeast-2.rds.amazonaws.com` (PostgreSQL 14)
- **S3**: `fab-sketch-media-xp8zu198`

### Network
- **VPC**: `vpc-091bd319f1b9782a7`
- **Private Subnet**: `subnet-05ee83d9ea30a7fb8` (EC2)
- **Public Subnets**: ALB endpoints

## 🚀 Infrastructure Management

### Initial Setup (Already Done)
```bash
terraform init
terraform plan
terraform apply
```

### Current Status
- ✅ Infrastructure deployed via Terraform
- ✅ EC2 instance running Django backend
- ✅ ALB routing traffic to EC2
- ✅ RDS PostgreSQL connected
- ✅ S3 bucket for media files

## 🔄 Application Deployment

**Important**: Infrastructure (Terraform) vs Application (Django) deployment are separate!

### Infrastructure Changes
```bash
# Only when changing AWS resources
terraform plan
terraform apply
```

### Application Deployment
```bash
# For Django code changes - use backend deployment script
cd ../fab_sketch_backend
./deploy/deploy.sh
```

## 📋 Resource Details

### EC2 Configuration
- **Instance Type**: t3.medium
- **OS**: Amazon Linux 2023
- **Location**: Private subnet (no direct internet access)
- **Access**: Through ALB only
- **SSH**: `ssh -i ~/.ssh/fabsketch-key ec2-user@10.0.10.18`

### ALB Configuration
- **DNS**: `fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com`
- **Target Group**: Routes to EC2:8000
- **Health Check**: `/health/` endpoint

### RDS Configuration
- **Engine**: PostgreSQL 14.20
- **Instance**: db.t3.micro
- **Database**: `fabsketchdb`
- **User**: `fabsketch`

## 🌐 Endpoints

- **API Base**: `http://fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com/api/`
- **Admin**: `http://fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com/admin/`
- **Health**: `http://fab-sketch-alb-1270525117.ap-northeast-2.elb.amazonaws.com/health/`

## 🔧 Infrastructure Updates

### Adding New AWS Resources
1. Edit Terraform files (`.tf`)
2. Plan changes: `terraform plan`
3. Apply changes: `terraform apply`

### Modifying Existing Resources
1. Update Terraform configuration
2. Review plan: `terraform plan`
3. Apply: `terraform apply`

## 💰 Cost Estimation

**Monthly cost (~$25-35)**:
- EC2 t3.medium: ~$15-20
- RDS t3.micro: ~$12
- ALB: ~$3
- S3: ~$1

## 🐛 Infrastructure Troubleshooting

### EC2 Issues
```bash
# Check instance status
aws ec2 describe-instances --instance-ids i-0241eb14f5097a359

# SSH to instance
ssh -i ~/.ssh/fabsketch-key ec2-user@10.0.10.18
```

### ALB Issues
```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check ALB status
aws elbv2 describe-load-balancers --names fab-sketch-alb
```

### RDS Issues
```bash
# Check RDS status
aws rds describe-db-instances --db-instance-identifier fab-sketch-db
```

## 🔐 Security Configuration

### Current Setup
- ✅ EC2 in private subnet
- ✅ RDS in private subnet
- ✅ Security groups properly configured
- ✅ IAM roles with minimal permissions
- ✅ SSH key-based access

### Security Groups
- **ALB SG**: Allows HTTP/HTTPS from internet
- **EC2 SG**: Allows traffic from ALB only
- **RDS SG**: Allows PostgreSQL from EC2 only

## 🗑️ Cleanup

```bash
# Destroy all infrastructure
terraform destroy
```

**Warning**: This will delete all data including the database!

## 📝 Migration Notes

### From ECS to EC2 (Completed)
- **Previous**: ECS Fargate containers
- **Current**: EC2 instance with Django
- **Benefits**: Simpler deployment, lower cost
- **Trade-offs**: Manual scaling, single point of failure

### Future Improvements
- [ ] Auto Scaling Group for high availability
- [ ] Multi-AZ deployment
- [ ] CloudFront CDN
- [ ] Container deployment (EKS)
- [ ] Monitoring and alerting
