variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "swayatt-devops-task"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "container_port" {
  description = "Port exposed by the Docker container"
  type        = number
  default     = 3000
}

variable "github_repo_url" {
  description = "GitHub repository URL for the application"
  type        = string
  default     = "https://github.com/Amaansaquib/devops-task.git"
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "Amaansaquib/devops-task"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t3.medium"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Jenkins and ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Update with your IP for better security
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = ""
}
