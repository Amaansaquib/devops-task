pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = "${ECR_REPOSITORY_URI}"
        ECS_CLUSTER = "${ECS_CLUSTER_NAME}"
        ECS_SERVICE = "${ECS_SERVICE_NAME}"
        IMAGE_TAG = "${BUILD_NUMBER}"
        GITHUB_REPO = "https://github.com/Amaansaquib/devops-task.git"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
                sh 'ls -la'
                sh 'cat package.json'
            }
        }
        
        stage('Environment Check') {
            steps {
                echo 'Checking build environment...'
                sh 'node --version'
                sh 'npm --version'
                sh 'docker --version'
                sh 'aws --version'
                sh 'echo "ECR Repository: $ECR_REPOSITORY"'
                sh 'echo "ECS Cluster: $ECS_CLUSTER"'
                sh 'echo "ECS Service: $ECS_SERVICE"'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm install'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running application tests...'
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                    sh "docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REPOSITORY}:latest"
                    sh "docker images | grep ${ECR_REPOSITORY.split('/')[1]}"
                }
            }
        }
        
        stage('Login to ECR') {
            steps {
                echo 'Logging into Amazon ECR...'
                script {
                    sh "/usr/local/bin/ecr-login.sh"
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                echo 'Pushing Docker image to ECR...'
                script {
                    sh "docker push ${ECR_REPOSITORY}:${IMAGE_TAG}"
                    sh "docker push ${ECR_REPOSITORY}:latest"
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Deploying to Amazon ECS...'
                script {
                    sh """
                        echo "Updating ECS service: ${ECS_SERVICE} in cluster: ${ECS_CLUSTER}"
                        aws ecs update-service \
                            --cluster ${ECS_CLUSTER} \
                            --service ${ECS_SERVICE} \
                            --force-new-deployment \
                            --region ${AWS_REGION}
                        
                        echo "Waiting for deployment to complete..."
                        aws ecs wait services-stable \
                            --cluster ${ECS_CLUSTER} \
                            --services ${ECS_SERVICE} \
                            --region ${AWS_REGION}
                        
                        echo "Deployment completed successfully!"
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up Docker images...'
            sh 'docker system prune -f'
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            echo "Application deployed to ECS cluster: ${ECS_CLUSTER}"
        }
        failure {
            echo '❌ Pipeline failed! Check the logs above for details.'
        }
    }
}
