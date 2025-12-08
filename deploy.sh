#!/bin/bash

set -e

echo "🚀 FabSketch AWS Deployment Script"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please create it from terraform.tfvars.example"
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Planning deployment..."
terraform plan

# Apply infrastructure
echo "🏗️ Deploying infrastructure..."
terraform apply -auto-approve

# Get ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "📦 ECR Repository: $ECR_URL"

# Build and push Docker image
echo "🐳 Building and pushing Docker image..."
cd ../fab_sketch_backend

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(terraform -chdir=../fab_sketch_infra output -raw aws_region || echo "ap-northeast-2")

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Build and push image
docker build -t fab-sketch-app .
docker tag fab-sketch-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

echo "✅ Deployment completed!"
echo "🌐 API URL: $(terraform -chdir=../fab_sketch_infra output -raw api_url)"
echo "📦 S3 Bucket: $(terraform -chdir=../fab_sketch_infra output -raw s3_bucket_name)"
