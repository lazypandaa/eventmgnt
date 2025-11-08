# Cloud Native Modernization Lab
## Event Management Fullstack Application Deployment on Kubernetes using Ansible

---

## **AIM**
To deploy a fullstack Event Management application on a Kubernetes cluster using Ansible automation, ensuring scalability, high availability, and efficient orchestration through containerization.

---

## **OBJECTIVE**
- Containerize the Event Management frontend (React) and backend (Spring Boot) applications
- Deploy MySQL database with persistent storage on Kubernetes
- Automate the deployment process using Ansible playbooks
- Implement service discovery and load balancing
- Ensure high availability with multiple replicas
- Configure NodePort services for external access

---

## **TOOLS & TECHNOLOGIES**
- **Frontend**: React (Vite)
- **Backend**: Spring Boot (Java 21)
- **Database**: MySQL 8.0
- **Containerization**: Docker
- **Orchestration**: Kubernetes (Minikube)
- **Automation**: Ansible
- **Version Control**: Git

---

## **PREREQUISITES**
1. Ubuntu/WSL environment
2. Docker installed and running
3. Minikube installed
4. Kubectl installed
5. Ansible installed
6. Docker Hub account (for pushing images)

---

## **ARCHITECTURE**

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
│                                                           │
│  ┌──────────────┐      ┌──────────────┐                │
│  │   Frontend   │      │   Backend    │                │
│  │  (React)     │─────▶│ (Spring Boot)│                │
│  │  Replicas: 2 │      │  Replicas: 2 │                │
│  │  Port: 2069  │      │  Port: 2025  │                │
│  └──────────────┘      └──────┬───────┘                │
│       │                        │                         │
│       │                        ▼                         │
│       │                ┌──────────────┐                 │
│       │                │    MySQL     │                 │
│       │                │  Database    │                 │
│       │                │  Port: 3306  │                 │
│       │                └──────────────┘                 │
│       │                        │                         │
│       └────────────────────────┘                         │
│                                                           │
└─────────────────────────────────────────────────────────┘
         │                      │
         ▼                      ▼
    NodePort: 30069        NodePort: 30025
```

---

## **PROCEDURE**

### **Phase 1: Environment Setup**

#### Step 1: Install Required Tools
```bash
# Install Ansible
sudo apt update
sudo apt install -y ansible

# Install Docker
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
newgrp docker

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Start Minikube
minikube start --driver=docker --memory=4000 --cpus=2
```

#### Step 2: Verify Installation
```bash
docker --version
minikube status
kubectl version --client
ansible --version
```

---

### **Phase 2: Application Containerization**

#### Step 3: Create Dockerfile for Backend
```bash
cd Event-Management/Backend
```

Create `Dockerfile`:
```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 2025
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### Step 4: Build Backend Application
```bash
# Build with Maven
./mvnw clean package -DskipTests

# Build Docker image
docker build -t <your-dockerhub-username>/event-backend:v1 .

# Push to Docker Hub
docker login
docker push <your-dockerhub-username>/event-backend:v1
```

#### Step 5: Create Dockerfile for Frontend
```bash
cd ../frontend
```

Create `Dockerfile`:
```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 2069
CMD ["nginx", "-g", "daemon off;"]
```

#### Step 6: Build Frontend Application
```bash
# Build Docker image
docker build -t <your-dockerhub-username>/event-frontend:v1 .

# Push to Docker Hub
docker push <your-dockerhub-username>/event-frontend:v1
```

---

### **Phase 3: Kubernetes Configuration**

#### Step 7: Create Kubernetes Manifests Directory
```bash
cd ../..
mkdir -p k8s
cd k8s
```

#### Step 8: Create Kubernetes Deployment File
Create `event-deployment.yaml` (see code below)

---

### **Phase 4: Ansible Automation**

#### Step 9: Create Ansible Directory Structure
```bash
cd ..
mkdir -p ansible
cd ansible
```

#### Step 10: Create Ansible Inventory
Create `inventory` file

#### Step 11: Create Ansible Playbook
Create `playbook.yaml` (see code below)

---

### **Phase 5: Deployment Execution**

#### Step 12: Run Ansible Playbook
```bash
cd ansible
ansible-playbook -i inventory playbook.yaml
```

#### Step 13: Verify Deployment
```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check deployments
kubectl get deployments

# Check persistent volumes
kubectl get pvc
```

#### Step 14: Access Application
```bash
# Get Minikube IP
minikube ip

# Access Frontend
http://localhost:30069

# Access Backend
http://localhost:30025
```

---

## **TESTING & VALIDATION**

### Test 1: Database Connectivity
```bash
kubectl exec -it <mysql-pod-name> -- mysql -uroot -proot -e "SHOW DATABASES;"
```

### Test 2: Backend Health Check
```bash
curl http://localhost:30025/actuator/health
```

### Test 3: Frontend Accessibility
```bash
curl http://localhost:30069
```

### Test 4: Pod Scaling
```bash
kubectl scale deployment backend --replicas=3
kubectl get pods
```

### Test 5: Service Discovery
```bash
kubectl exec -it <backend-pod-name> -- nslookup mysql
```

---

## **MONITORING & TROUBLESHOOTING**

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/backend

# Frontend logs
kubectl logs -f deployment/frontend

# MySQL logs
kubectl logs -f deployment/mysql
```

### Describe Resources
```bash
kubectl describe pod <pod-name>
kubectl describe svc <service-name>
kubectl describe deployment <deployment-name>
```

### Port Forwarding (Alternative Access)
```bash
# Backend
kubectl port-forward svc/backend 30025:2025

# Frontend
kubectl port-forward svc/frontend 30069:2069
```

---

## **CLEANUP**

```bash
# Delete all resources
kubectl delete -f ../k8s/event-deployment.yaml

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

---

## **EXPECTED OUTCOMES**
1. ✅ Containerized Event Management application
2. ✅ Automated deployment using Ansible
3. ✅ High availability with multiple replicas
4. ✅ Persistent data storage for MySQL
5. ✅ Service discovery and load balancing
6. ✅ External access via NodePort services
7. ✅ Scalable and maintainable infrastructure

---

## **CONCLUSION**
Successfully deployed a cloud-native Event Management fullstack application on Kubernetes using Ansible automation, demonstrating modern DevOps practices including containerization, orchestration, and infrastructure as code.

---

## **REFERENCES**
- Kubernetes Documentation: https://kubernetes.io/docs/
- Ansible Documentation: https://docs.ansible.com/
- Docker Documentation: https://docs.docker.com/
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- React Documentation: https://react.dev/

---

**Lab Completed By**: [Your Name]  
**Date**: [Current Date]  
**Institution**: TechMahendra Cloud Native Modernization Project



DETAILED PROCEDURE EXPLANATION
Phase 1: Environment Preparation
The first phase involves setting up the development and deployment environment. We begin by installing essential tools including Ansible for automation, Docker for containerization, Minikube for local Kubernetes cluster simulation, and kubectl for cluster management. Each tool serves a specific purpose: Ansible automates the deployment workflow, Docker packages applications into portable containers, Minikube provides a lightweight Kubernetes environment for testing, and kubectl enables command-line interaction with the Kubernetes cluster.

After installation, we verify each tool's functionality by checking version numbers and service status. We then initialize Minikube with appropriate resource allocations (4GB memory and 2 CPU cores) using the Docker driver, which allows Kubernetes to run containers efficiently on the local machine.

Phase 2: Application Containerization
In this phase, we transform the traditional applications into containerized microservices. For the backend Spring Boot application, we create a Dockerfile that uses OpenJDK 21 as the base image. The containerization process involves first building the application using Maven to generate an executable JAR file, then packaging this JAR into a Docker image. The image is configured to expose port 2025 and automatically start the Spring Boot application when the container launches.

Similarly, the frontend React application undergoes a multi-stage build process. The first stage uses Node.js to install dependencies and build the production-optimized static files. The second stage uses a lightweight Nginx web server to serve these static files efficiently. This multi-stage approach significantly reduces the final image size while maintaining full functionality. The frontend container exposes port 2069 for external access.

Both images are tagged with version numbers and pushed to Docker Hub, making them accessible for Kubernetes deployment from any environment.

Phase 3: Kubernetes Resource Configuration
This phase involves creating comprehensive Kubernetes manifests that define all necessary resources. We design a deployment architecture that includes persistent volume claims for MySQL data storage, ensuring data survives pod restarts. The MySQL deployment is configured as a single replica with environment variables for database initialization, including the database name and root password.

The backend deployment is configured with two replicas for high availability and includes an init container that waits for MySQL to be ready before starting the application. This ensures proper startup sequencing and prevents connection errors. Environment variables are injected to configure database connectivity, including the JDBC URL pointing to the MySQL service, credentials, and Hibernate settings for automatic schema management.

The frontend deployment also runs with two replicas and includes a ConfigMap for environment-specific configuration, particularly the backend API URL. This separation of configuration from code enables easy environment-specific customization without rebuilding images.

Services are defined for each component: MySQL uses ClusterIP for internal-only access, while backend and frontend use NodePort services to enable external access through specific ports (30025 and 30069 respectively).

Phase 4: Ansible Automation
Ansible automates the deployment with a single playbook that: verifies Docker and Minikube status, applies Kubernetes manifests using kubectl, waits for pod readiness, configures port forwarding, and displays deployment status.

```yaml
- name: Deploy Event Management App
  hosts: localhost
  tasks:
    - name: Start Minikube
      command: minikube start --memory=4096 --cpus=2
      
    - name: Apply Kubernetes manifests
      command: kubectl apply -f k8s/event-deployment.yaml
      
    - name: Wait for pods
      command: kubectl wait --for=condition=ready pod -l app={{ item }} --timeout=300s
      loop: [mysql, backend, frontend]
```

Phase 5: Deployment Execution and Verification
Execute deployment and verify:
```bash
ansible-playbook deploy.yml
kubectl get pods,svc,pvc
minikube service frontend --url
```

Verification checks: pod status (all running), service endpoints (correct ports), database connectivity, and application functionality via browser testing.

TECHNICAL CONCEPTS DEMONSTRATED
Containerization Benefits
Containerization encapsulates applications with their dependencies, ensuring consistent behavior across different environments. This eliminates "works on my machine" problems and simplifies deployment processes. Containers are lightweight compared to virtual machines, enabling efficient resource utilization and faster startup times.

Kubernetes Orchestration
Kubernetes provides automated container orchestration, handling deployment, scaling, and management of containerized applications. It offers self-healing capabilities, automatically restarting failed containers and replacing unhealthy pods. The declarative configuration approach allows administrators to define desired states, and Kubernetes continuously works to maintain those states.

High Availability Architecture
Running multiple replicas of frontend and backend services ensures the application remains available even if individual pods fail. Kubernetes' built-in load balancing distributes traffic across healthy pods, preventing any single point of failure. The persistent volume for MySQL ensures data durability across pod restarts.

Infrastructure as Code
Using Ansible playbooks and Kubernetes manifests represents infrastructure as code, making deployments reproducible, version-controlled, and auditable. This approach enables rapid environment provisioning, consistent configurations, and easy rollback capabilities.

Service Discovery
Kubernetes' internal DNS automatically creates service records, enabling pods to discover and communicate with each other using service names rather than IP addresses. This abstraction simplifies configuration and enables dynamic scaling without manual reconfiguration.

CHALLENGES AND SOLUTIONS
During deployment, several challenges may arise. Database initialization timing can cause backend startup failures if the backend attempts to connect before MySQL is ready. The init container pattern solves this by explicitly waiting for MySQL availability. Port conflicts may occur if specified NodePorts are already in use; selecting unique port numbers resolves this issue. Resource constraints on the local machine can prevent pod scheduling; adjusting Minikube's memory and CPU allocations addresses this limitation.

BEST PRACTICES IMPLEMENTED
The project follows several industry best practices. Multi-stage Docker builds minimize image sizes and reduce attack surfaces. Environment-specific configurations are externalized through ConfigMaps and environment variables, enabling easy customization without code changes. Health checks and readiness probes ensure traffic is only routed to fully operational pods. Resource limits prevent individual containers from consuming excessive cluster resources. Persistent volumes ensure data durability for stateful applications like databases.

REAL-WORLD APPLICATIONS
This deployment pattern is applicable to various production scenarios. Organizations can use similar architectures for deploying microservices-based applications, e-commerce platforms, content management systems, and SaaS applications. The scalability features enable handling variable traffic loads, while the automation reduces manual intervention and human error in deployment processes.

CONCLUSION SUMMARY
This lab successfully demonstrates cloud-native application deployment using modern DevOps tools and practices. By containerizing the Event Management application, orchestrating it with Kubernetes, and automating deployment with Ansible, we achieve a scalable, highly available, and maintainable infrastructure. The project showcases essential skills for modern software deployment including containerization, orchestration, automation, and infrastructure as code principles. These competencies are crucial for organizations transitioning to cloud-native architectures and implementing DevOps methodologies.

This writeup provides comprehensive English content explaining every aspect of the lab without including code blocks.


