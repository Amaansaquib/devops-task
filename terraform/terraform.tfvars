# AWS Configuration
aws_region = "us-east-1"
project_name = "swayatt-devops-task"
environment = "production"

# Application Configuration
container_port = 3000
github_repo_url = "https://github.com/Amaansaquib/devops-task.git"
github_repo_name = "Amaansaquib/devops-task"

# Infrastructure Configuration (Using Free Tier t3.small - 2 vCPU, 2GB RAM)
jenkins_instance_type = "t3.small"
allowed_cidr_blocks = ["0.0.0.0/0"]
enable_container_insights = true

# SSH Key
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCszyraIFdUSeTNIqhpy1rzGJbY3grnTjOZ/2By8H9djUCYQQpHvfb3FPJxyrpRVs4GQnM4B0BRsikSHeeGP6mJRVVtIDcfcvFW/CTIm8xSWqB19OqU4OTpl4t+V7LgxFOsvzXmWAnCq/7AgTCUfUEsTflggUvtL45z0FSuQnUwgeNZaxauol7UkHm2vbhd9rRmIZeswrZknsZWQFStjPQFx8IOC3gTC6799TnbOfoiEqNGChibJSpWm8j7k8NQ8ac/VgiwWYe6raCjHqxye8fRX9w7qfcw1AMwOgbC1/1JRlMEerAtq79P0cvpBE9JZDTl9eTU7jEMZSqU63Oz7/fQ9vAPoX0DUTqkC+k/J2SEyvuRNJM/ShXRZh+SEJXM3jt++B/TwNchvwud4TN28MnrUZ2QPEZMWPWA5ODHbktCaUoqutX1jHNE7VvWYEVN0QqWe9YbHJAeYPirSbs71TpPw7aMWHTph89/lCMF91jL8GwtTDO9ZhOstMxGnlnyn/syqUb1bGmIWphGEobvBJMXYGU+tZRESMNE66z9N1amHJ1SvOYyQRZh2U5Vqw0X/Ji8WthyT9DmZv9uA5I1BSq/LxgPZjaNDKOjHMVL92RHuSdjvDzVq7XQFZgGwDJt8HARKuHAIqGFxVeMyglLdEOhwGqPJ/UjEuvRrg4d8o9OhQ== secure_ubuntu@LAPTOP-KL260CKN"
