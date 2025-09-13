pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '662810865233.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'swayatt-devops-task'
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
        IMAGE_LATEST = "${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"
        
        // ECS Configuration  
        ECS_CLUSTER = 'swayatt-devops-task-0b9a6856-cluster'
        ECS_SERVICE = 'swayatt-devops-task-0b9a6856-service'
        ECS_TASK_DEFINITION = 'swayatt-devops-task-0b9a6856-task'
        
        // Jenkins Configuration
        AWS_CREDENTIALS = 'aws-credentials'
    }
    
    stages {
        stage('📥 Checkout') {
            steps {
                echo '🔄 Checking out source code from GitHub...'
                checkout scm
                
                script {
                    sh '''
                        echo "Repository: ${GIT_URL}"
                        echo "Branch: ${GIT_BRANCH}"
                        echo "Commit: ${GIT_COMMIT}"
                        echo "Build Number: ${BUILD_NUMBER}"
                        ls -la
                    '''
                }
            }
        }
        
        stage('🏗️ Build') {
            steps {
                echo '📦 Installing Node.js dependencies and running tests...'
                
                script {
                    sh '''
                        echo "Node.js version: $(node --version)"
                        echo "NPM version: $(npm --version)"
                        
                        # Install dependencies
                        npm install
                        
                        # Display package info
                        cat package.json
                        
                        # List installed packages
                        npm list --depth=0
                    '''
                    
                    sh '''
                        echo "Running application tests..."
                        npm test
                        
                        # Additional test validations
                        echo "Validating application files..."
                        test -f app.js && echo "✅ app.js found"
                        test -f package.json && echo "✅ package.json found"
                        test -f Dockerfile && echo "✅ Dockerfile found"
                        test -f logoswayatt.png && echo "✅ Logo file found"
                    '''
                }
            }
        }
        
        stage('🐳 Dockerize') {
            steps {
                echo '🔨 Building Docker container image...'
                
                script {
                    sh '''
                        echo "Building Docker image: ${IMAGE_URI}"
                        docker build -t ${IMAGE_URI} .
                        docker tag ${IMAGE_URI} ${IMAGE_LATEST}
                        
                        # Display image information
                        docker images | grep ${ECR_REPOSITORY}
                        
                        # Get image size and details
                        docker inspect ${IMAGE_URI} --format='{{.Size}}' | awk '{print "Image size: " $1/1024/1024 " MB"}'
                        
                        echo "✅ Docker image built successfully!"
                    '''
                }
            }
        }
        
        stage('📤 Push to ECR') {
            steps {
                echo '🚀 Pushing Docker image to Amazon ECR...'
                
                withCredentials([aws(credentialsId: 'aws-credentials', region: 'us-east-1')]) {
                    script {
                        sh '''
                            echo "Logging into Amazon ECR..."
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            
                            echo "Pushing images to ECR repository..."
                            docker push ${IMAGE_URI}
                            docker push ${IMAGE_LATEST}
                            
                            # Verify images in ECR
                            echo "Verifying images in ECR repository..."
                            aws ecr describe-images --repository-name ${ECR_REPOSITORY} --region ${AWS_REGION} --query 'imageDetails[0:3].{ImageTag:imageTags[0],Size:imageSizeInBytes,PushedAt:imagePushedAt}' --output table
                            
                            echo "✅ Images pushed to ECR successfully!"
                        '''
                    }
                }
            }
        }
        
        stage('🚀 Deploy to ECS') {
            steps {
                echo '⚙️ Deploying container to Amazon ECS...'
                
                withCredentials([aws(credentialsId: 'aws-credentials', region: 'us-east-1')]) {
                    script {
                        sh '''
                            echo "Current ECS service status:"
                            aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --region ${AWS_REGION} --query 'services[0].{ServiceName:serviceName,Status:status,Running:runningCount,Desired:desiredCount,Pending:pendingCount}' --output table
                            
                            echo "Initiating ECS service deployment..."
                            aws ecs update-service \\
                                --cluster ${ECS_CLUSTER} \\
                                --service ${ECS_SERVICE} \\
                                --force-new-deployment \\
                                --region ${AWS_REGION}
                            
                            echo "⏳ Waiting for deployment to complete..."
                            
                            # Wait for service to become stable (with timeout)
                            timeout 600 aws ecs wait services-stable \\
                                --cluster ${ECS_CLUSTER} \\
                                --services ${ECS_SERVICE} \\
                                --region ${AWS_REGION} || {
                                echo "⚠️ Deployment timeout after 10 minutes"
                                exit 1
                            }
                            
                            echo "✅ ECS deployment completed successfully!"
                        '''
                    }
                }
            }
        }
        
        stage('🔍 Verify Deployment') {
            steps {
                echo '✅ Verifying deployment and application health...'
                
                withCredentials([aws(credentialsId: 'aws-credentials', region: 'us-east-1')]) {
                    script {
                        sh '''
                            echo "=== DEPLOYMENT VERIFICATION ==="
                            
                            # Check ECS service status
                            echo "ECS Service Status:"
                            aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --region ${AWS_REGION} --query 'services[0].{ServiceName:serviceName,Status:status,Running:runningCount,Desired:desiredCount,TaskDefinition:taskDefinition}' --output table
                            
                            # Check running tasks
                            echo "Running Tasks:"
                            aws ecs list-tasks --cluster ${ECS_CLUSTER} --service-name ${ECS_SERVICE} --region ${AWS_REGION} --query 'taskArns' --output table
                            
                            # Get Load Balancer DNS
                            ALB_DNS=$(aws elbv2 describe-load-balancers --region ${AWS_REGION} --query 'LoadBalancers[?contains(LoadBalancerName,`swayatt-devops-task`)].DNSName' --output text)
                            
                            echo "Application URL: http://$ALB_DNS"
                            
                            # Test application endpoint
                            echo "Testing application endpoint..."
                            for i in {1..5}; do
                                echo "Health check attempt $i/5..."
                                if curl -f -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/ | grep -q "200"; then
                                    echo "✅ Application is responding correctly!"
                                    break
                                else
                                    echo "⏳ Waiting for application to be ready..."
                                    sleep 30
                                fi
                                
                                if [ $i -eq 5 ]; then
                                    echo "❌ Application health check failed after 5 attempts"
                                    exit 1
                                fi
                            done
                            
                            # Display final deployment summary
                            echo ""
                            echo "=== DEPLOYMENT SUMMARY ==="
                            echo "✅ Build: Dependencies installed and tests passed"
                            echo "✅ Dockerize: Container image built successfully"  
                            echo "✅ Push: Image pushed to ECR registry"
                            echo "✅ Deploy: Container deployed to ECS"
                            echo "✅ Verify: Application is healthy and responding"
                            echo ""
                            echo "🌐 Application URL: http://$ALB_DNS"
                            echo "📊 Jenkins Build: ${BUILD_URL}"
                            echo "🐳 Docker Image: ${IMAGE_URI}"
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up build artifacts...'
            script {
                sh '''
                    # Clean up Docker images to save space
                    docker system prune -f
                    
                    # Clean up temporary files
                    rm -f *.tmp *.log 2>/dev/null || true
                '''
            }
        }
        
        success {
            echo '''
                🎉 PIPELINE COMPLETED SUCCESSFULLY! 🎉
                
                ═══════════════════════════════════════
                ✅ All pipeline stages completed:
                   📥 Checkout: Source code retrieved
                   🏗️  Build: Dependencies installed & tests passed  
                   🐳 Dockerize: Container image built
                   📤 Push: Image pushed to AWS ECR
                   🚀 Deploy: Deployed to AWS ECS  
                   🔍 Verify: Application health confirmed
                ═══════════════════════════════════════
                
                🌐 Your application is live and ready!
            '''
        }
        
        failure {
            echo '''
                ❌ PIPELINE FAILED!
                
                Please check the console output above for error details.
                Common issues to check:
                - AWS credentials configuration
                - Docker service availability  
                - Network connectivity to AWS services
                - Application code syntax errors
                
                💡 Fix the issues and push changes to trigger a new build.
            '''
        }
        
        unstable {
            echo '⚠️ Pipeline completed with warnings. Check the logs for details.'
        }
    }
}
