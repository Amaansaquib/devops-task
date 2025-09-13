#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/jenkins-userdata.log)
exec 2>&1

echo "=== Jenkins Ubuntu Setup Started at $(date) ==="

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker
systemctl enable docker
systemctl start docker

# Install Java 17 (for Jenkins)
apt-get install -y openjdk-17-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
apt-get update
apt-get install -y jenkins

# Install Node.js 18 (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Configure Jenkins user
usermod -aG docker jenkins

# Set up Jenkins configuration
cat > /etc/default/jenkins << 'JENKINS_CONFIG'
HTTP_PORT=8080
JENKINS_OPTS="--httpPort=8080"
JAVA_ARGS="-Djava.awt.headless=true -Xmx1536m -Xms512m -XX:MaxMetaspaceSize=384m -XX:+UseG1GC"
JENKINS_CONFIG

# Start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Create ECR login script
cat > /usr/local/bin/ecr-login.sh << 'ECR_SCRIPT'
#!/bin/bash
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_uri}
ECR_SCRIPT

chmod +x /usr/local/bin/ecr-login.sh

# Set environment variables for Jenkins
cat >> /etc/environment << 'ENV_VARS'
ECR_REPOSITORY_URI=${ecr_repository_uri}
ECS_CLUSTER_NAME=${ecs_cluster_name}
ECS_SERVICE_NAME=${ecs_service_name}
AWS_REGION=${aws_region}
AWS_DEFAULT_REGION=${aws_region}
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV_VARS

# Wait for Jenkins to initialize
sleep 90

# Verification
echo "=== Installation Verification ==="
java --version
node --version
npm --version
docker --version
aws --version

# Test as jenkins user
echo "=== Testing as jenkins user ==="
sudo -u jenkins java --version
sudo -u jenkins node --version
sudo -u jenkins npm --version
sudo -u jenkins docker --version
sudo -u jenkins aws --version

# Check Jenkins status
systemctl status jenkins

echo "=== Jenkins Ubuntu Setup Completed at $(date) ==="
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "SSH Connection: ubuntu@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
