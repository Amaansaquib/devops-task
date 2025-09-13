#!/bin/bash
set -e

# Update system
yum update -y

# Install required packages
yum install -y docker git curl unzip wget htop

# Install Java 17 (required for Jenkins)
amazon-linux-extras enable java-openjdk17 || true
yum install -y java-17-openjdk java-17-openjdk-devel

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# Install Node.js 18 (for your Node.js application)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs npm

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Start and enable services
systemctl enable docker
systemctl start docker
systemctl enable jenkins
systemctl start jenkins

# Add jenkins user to docker group
usermod -a -G docker jenkins

# Create ECR login script
cat > /usr/local/bin/ecr-login.sh << 'SCRIPT'
#!/bin/bash
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_uri}
SCRIPT

chmod +x /usr/local/bin/ecr-login.sh

# Optimize Jenkins for t3.small instance (2GB RAM)
cat > /etc/sysconfig/jenkins << 'JENKINS_ENV'
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Xmx1536m -Xms512m -XX:MaxMetaspaceSize=384m -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom"
JENKINS_OPTS="--httpPort=8080 --prefix="
ECR_REPOSITORY_URI=${ecr_repository_uri}
ECS_CLUSTER_NAME=${ecs_cluster_name}
ECS_SERVICE_NAME=${ecs_service_name}
AWS_REGION=${aws_region}
AWS_DEFAULT_REGION=${aws_region}
GITHUB_REPO_URL=https://github.com/Amaansaquib/devops-task.git
JENKINS_ENV

# Optional: Configure swap for extra safety (though not needed with 2GB)
if [ $(free | grep Mem | awk '{print $2}') -lt 2000000 ]; then
    fallocate -l 512M /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
fi

# Configure Docker daemon for better performance
cat > /etc/docker/daemon.json << 'DOCKER_CONFIG'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
DOCKER_CONFIG

systemctl restart docker
systemctl enable docker

# Wait for Jenkins to start
sleep 45

# Create a comprehensive log file
cat > /var/log/jenkins-userdata.log << 'LOG'
==================================================
Jenkins Installation Completed Successfully
==================================================
Date: $(date)
Instance Type: t3.small (Free Tier eligible)
CPU: 2 vCPU
Memory: 2GB RAM
Java Heap Size: 1.5GB max
==================================================

Jenkins Initial Setup:
- URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080
- Initial Admin Password: /var/lib/jenkins/secrets/initialAdminPassword

Services Status:
LOG

systemctl status jenkins --no-pager >> /var/log/jenkins-userdata.log
systemctl status docker --no-pager >> /var/log/jenkins-userdata.log

# Show system resources
echo "" >> /var/log/jenkins-userdata.log
echo "System Resources:" >> /var/log/jenkins-userdata.log
free -h >> /var/log/jenkins-userdata.log
echo "" >> /var/log/jenkins-userdata.log
lscpu >> /var/log/jenkins-userdata.log

echo "Setup completed successfully!" >> /var/log/jenkins-userdata.log
