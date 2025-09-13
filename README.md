# DevOps CI/CD Pipeline - Complete Infrastructure & Automation

A comprehensive DevOps solution demonstrating modern CI/CD practices with containerization, infrastructure as code, and automated deployment on AWS.

## 🏗️ Architecture Overview

┌─────────────┐ ┌──────────────┐ ┌─────────────┐ ┌──────────────┐ ┌─────────────┐
│ Developer │───▶│ GitHub │───▶│ Jenkins │───▶│ AWS ECR │───▶│ AWS ECS │
│ │ │ Repository │ │ Ubuntu │ │ Container │ │ Fargate │
└─────────────┘ └──────────────┘ └─────────────┘ └──────────────┘ └─────────────┘
│ │ │
▼ ▼ ▼
┌──────────────┐ ┌─────────────┐ ┌─────────────┐
│ Webhook │ │ Docker │ │ ALB │
│ Trigger │ │ Build │ │Load Balancer│
└──────────────┘ └─────────────┘ └─────────────┘



### Architecture Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Source Control** | GitHub | Code repository with webhook automation |
| **CI/CD Server** | Jenkins (Ubuntu 22.04) | Build automation and deployment orchestration |
| **Containerization** | Docker | Application packaging and consistency |
| **Container Registry** | AWS ECR | Secure image storage and versioning |
| **Orchestration** | AWS ECS Fargate | Serverless container management |
| **Load Balancing** | AWS ALB | Traffic distribution and high availability |
| **Infrastructure** | Terraform | Infrastructure as Code (IaC) |
| **Monitoring** | CloudWatch | Logging and metrics collection |

## 🚀 Pipeline Stages

The CI/CD pipeline consists of 6 automated stages:

1. **📥 Checkout** - Clone source code from GitHub
2. **🏗️ Build** - Install dependencies (`npm install`) and run tests (`npm test`)
3. **🐳 Dockerize** - Build optimized container image with Node.js 18 Alpine
4. **📤 Push to Registry** - Upload image to AWS ECR with versioning
5. **🚀 Deploy** - Rolling deployment to ECS Fargate cluster (zero downtime)
6. **🔍 Verify** - Health checks and deployment validation

## 🛠️ Technologies Used

### Core Stack
- **Runtime**: Node.js 18 (Express.js application)
- **Containerization**: Docker with multi-stage builds
- **CI/CD**: Jenkins with Pipeline as Code
- **Infrastructure**: AWS (ECS, ECR, ALB, VPC, CloudWatch)
- **IaC**: Terraform for reproducible infrastructure

### Development Tools
- **Version Control**: Git with GitHub
- **Automation**: GitHub webhooks for trigger automation
- **Monitoring**: AWS CloudWatch for logs and metrics
- **Security**: IAM roles, security groups, encrypted storage

## 📁 Project Structure

devops-task/
├── app.js # Main Node.js application
├── package.json # Dependencies and scripts
├── Dockerfile # Container build instructions
├── Jenkinsfile # CI/CD pipeline definition
├── test.js # Application test suite
├── logoswayatt.png # Application asset
├── terraform/ # Infrastructure as Code
│ ├── main.tf # AWS provider configuration
│ ├── vpc.tf # Network infrastructure
│ ├── ecs.tf # Container orchestration
│ ├── alb.tf # Load balancer setup
│ ├── jenkins.tf # CI/CD server configuration
│ └── variables.tf # Configuration variables
└── README.md # Project documentation


## 🔧 Setup Instructions

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker Desktop installed
- GitHub account with repository access

### 1. Clone Repository

git clone https://github.com/Amaansaquib/devops-task.git
cd devops-task


### 2. Infrastructure Deployment

Navigate to Terraform directory
cd terraform

Initialize Terraform
terraform init

Review planned infrastructure
terraform plan

Deploy infrastructure
terraform apply -auto-approve

Get deployment outputs
terraform output


### 3. Jenkins Configuration

Get Jenkins initial password
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw jenkins_public_ip)
"sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

Access Jenkins web interface
echo "Jenkins URL: http://$(terraform output -raw jenkins_public_ip):8080"


**Jenkins Setup Steps:**
1. Unlock Jenkins with initial password
2. Install suggested plugins + AWS plugins
3. Create admin user
4. Configure AWS credentials in Jenkins
5. Create pipeline job linked to GitHub repository

### 4. GitHub Webhook Setup

1. Go to repository Settings → Webhooks
2. Add webhook: `http://JENKINS_IP:8080/github-webhook/`
3. Set content type: `application/json`
4. Enable push events

## 🔄 Pipeline Flow Explanation

### Automated Workflow

1. **Code Push** → Developer pushes code changes to GitHub main branch
2. **Webhook Trigger** → GitHub automatically notifies Jenkins via webhook
3. **Pipeline Start** → Jenkins initiates automated CI/CD pipeline
4. **Source Checkout** → Latest code retrieved from GitHub repository
5. **Dependency Installation** → `npm install` executed for Node.js dependencies
6. **Testing** → Application tests run to ensure code quality
7. **Container Build** → Docker image created with optimized multi-stage build
8. **Registry Push** → Image tagged with build number and pushed to ECR
9. **Service Update** → ECS service updated with new container image
10. **Health Verification** → Application health validated via load balancer
11. **Deployment Complete** → Users can access updated application

### Key Features

- ✅ **Zero Downtime Deployments** - Rolling updates with health checks
- ✅ **Automated Testing** - Quality gates prevent broken deployments  
- ✅ **Container Security** - Non-root user and minimal attack surface
- ✅ **Infrastructure Isolation** - VPC with public/private subnet architecture
- ✅ **Monitoring & Logging** - CloudWatch integration for observability
- ✅ **Scalable Architecture** - Auto-scaling ECS tasks based on demand

## 🌐 Live Deployment

- **Application URL**: http://swayatt-devops-task-0b9a6856-alb-133785310.us-east-1.elb.amazonaws.com
- **Jenkins Dashboard**: http://52.22.4.223:8080
- **Pipeline Status**: Automated builds triggered on every push

## 📊 Monitoring & Observability

- **Application Logs**: AWS CloudWatch Logs (`/ecs/swayatt-devops-task-*`)
- **Metrics Dashboard**: CloudWatch custom dashboard with ECS and ALB metrics
- **Health Checks**: Load balancer health monitoring with automatic failover
- **Build History**: Jenkins build artifacts and console logs

## 🔐 Security Features

- **IAM Roles**: Least privilege access for ECS tasks and Jenkins EC2
- **VPC Isolation**: Private subnets for application containers  
- **Security Groups**: Restrictive firewall rules for network access
- **Encrypted Storage**: EBS volumes and container images encrypted at rest
- **Container Security**: Non-root user execution and minimal base image

## 🏆 DevOps Best Practices Implemented

- **Infrastructure as Code** - Terraform for reproducible deployments
- **Pipeline as Code** - Jenkinsfile version controlled with application
- **Immutable Deployments** - Container images never modified, only replaced
- **Configuration Management** - Environment variables and secrets management
- **Automated Testing** - Quality gates integrated into pipeline
- **Monitoring First** - Observability built into architecture from day one

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/enhancement`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/enhancement`)
5. Create Pull Request


