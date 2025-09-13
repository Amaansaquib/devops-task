# Application Load Balancer DNS
output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "URL to access the deployed application"
  value       = "http://${aws_lb.main.dns_name}"
}

# Jenkins Server Information (using Elastic IP)
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins server (Elastic IP)"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins dashboard"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.jenkins.public_ip}"
}

# ECR Repository Information
output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# ECS Cluster Information
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

# VPC Information
output "vpc_id" {
  description = "VPC ID where resources are deployed"
  value       = aws_vpc.main.id
}

# CloudWatch Information
output "cloudwatch_log_group" {
  description = "CloudWatch log group for application logs"
  value       = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# Deployment Information
output "deployment_timestamp" {
  description = "Timestamp of infrastructure deployment"
  value       = timestamp()
}

output "resource_name_prefix" {
  description = "Prefix used for resource naming"
  value       = local.name_prefix
}

# Connection Information Summary
output "deployment_summary" {
  description = "Summary of deployment information"
  value = {
    application_url = "http://${aws_lb.main.dns_name}"
    jenkins_url     = "http://${aws_eip.jenkins.public_ip}:8080"
    ssh_command     = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.jenkins.public_ip}"
    ecr_repository  = aws_ecr_repository.app.repository_url
    ecs_cluster     = aws_ecs_cluster.main.name
    ecs_service     = aws_ecs_service.app.name
  }
}
