#!/bin/bash

echo "=========================================="
echo "Event Management Application Deployment"
echo "=========================================="

# Step 1: Build Docker Images
echo "Step 1: Building Docker images..."
cd Event-Management/Backend
docker build -t techmahendra/event-backend:v1 .
cd ../frontend
docker build -t techmahendra/event-frontend:v1 .
cd ../..

# Step 2: Push to Docker Hub (optional)
echo "Step 2: Pushing images to Docker Hub..."
read -p "Do you want to push images to Docker Hub? (y/n): " push_choice
if [ "$push_choice" = "y" ]; then
    docker push techmahendra/event-backend:v1
    docker push techmahendra/event-frontend:v1
fi

# Step 3: Run Ansible Playbook
echo "Step 3: Deploying to Kubernetes using Ansible..."
cd ansible
ansible-playbook -i inventory playbook.yaml

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
