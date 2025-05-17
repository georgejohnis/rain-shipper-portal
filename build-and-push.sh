#!/bin/bash
set -e

# Configuration
AWS_REGION="us-west-2"
ECR_REPOSITORY_NAME="rain-shipper-portal"
IMAGE_TAG="latest"

# Create ECR repository if it doesn't exist
echo "Checking if ECR repository exists..."
aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} --region ${AWS_REGION} || \
    aws ecr create-repository --repository-name ${ECR_REPOSITORY_NAME} --region ${AWS_REGION}

# Get ECR repository URI
ECR_REPOSITORY_URI=$(aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
echo "ECR Repository URI: ${ECR_REPOSITORY_URI}"

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}

# Set up Docker Buildx for multi-architecture builds
echo "Setting up Docker Buildx..."
docker buildx create --name multiarch-builder --use || true
docker buildx inspect --bootstrap

# Build and push multi-architecture image
echo "Building and pushing multi-architecture image..."
cd $(dirname "$0")
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag ${ECR_REPOSITORY_URI}:${IMAGE_TAG} \
    --push \
    .

echo "Image successfully built and pushed to ${ECR_REPOSITORY_URI}:${IMAGE_TAG}"

# Output the full image URI for use in Kubernetes manifests
echo "Full image URI: ${ECR_REPOSITORY_URI}:${IMAGE_TAG}"
echo ${ECR_REPOSITORY_URI}:${IMAGE_TAG} > image-uri.txt

echo "Build and push completed successfully!"
