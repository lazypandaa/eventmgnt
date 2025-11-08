# Event Management Application - Kubernetes Deployment

## Project Overview
Cloud-native Event Management fullstack application deployed on Kubernetes using Ansible for automation, ensuring scalability and high availability.

## Architecture
- **Frontend**: React (Vite) - Port 30069
- **Backend**: Spring Boot - Port 30025
- **Database**: MySQL 8.0 - Port 3306
- **Orchestration**: Kubernetes (Minikube)
- **Automation**: Ansible

## Prerequisites
```bash
# Install Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl

# Install Ansible
sudo apt install -y ansible
```

## Deployment Steps

### Option 1: Automated Deployment
```bash
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment
```bash
# 1. Build Docker images
cd Event-Management/Backend
docker build -t techmahendra/event-backend:v1 .

cd ../frontend
docker build -t techmahendra/event-frontend:v1 .

# 2. Start Minikube
minikube start --driver=docker --memory=4000 --cpus=2

# 3. Deploy using Ansible
cd ../../ansible
ansible-playbook -i inventory playbook.yaml
```

## Access Application
- **Frontend**: http://localhost:30069
- **Backend API**: http://localhost:30025
- **Admin Login**: Use credentials from application

## Kubernetes Resources
```bash
# View all resources
kubectl get all

# View pods
kubectl get pods

# View services
kubectl get svc

# View logs
kubectl logs -l app=backend
kubectl logs -l app=frontend

# Scale deployments
kubectl scale deployment backend --replicas=3
kubectl scale deployment frontend --replicas=3
```

## High Availability Features
- **Backend**: 2 replicas with load balancing
- **Frontend**: 2 replicas with load balancing
- **Database**: Persistent volume for data persistence
- **Init Containers**: Ensures MySQL is ready before backend starts
- **Health Checks**: Automatic pod restart on failure

## Troubleshooting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check service endpoints
kubectl get endpoints

# Restart deployment
kubectl rollout restart deployment backend
kubectl rollout restart deployment frontend

# Delete and redeploy
kubectl delete -f k8s/event-deployment.yaml
kubectl apply -f k8s/event-deployment.yaml
```

## Clean Up
```bash
# Delete all resources
kubectl delete -f k8s/event-deployment.yaml

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## Project Structure
```
cicdlab2/
├── Event-Management/
│   ├── Backend/
│   │   ├── Dockerfile
│   │   └── src/
│   └── frontend/
│       ├── Dockerfile
│       ├── nginx.conf
│       └── src/
├── k8s/
│   └── event-deployment.yaml
├── ansible/
│   ├── inventory
│   └── playbook.yaml
├── deploy.sh
└── README.md
```

## Author
TechMahendra - Cloud Native Modernization Project
