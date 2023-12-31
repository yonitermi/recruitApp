pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = 'recruit'  // Replace with your Docker image name
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Get the latest code from your Git repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build a Docker image from your Dockerfile
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Run the tests within the Docker container
                    sh "docker run ${DOCKER_IMAGE} python -m unittest discover tests"
                }
            }
        }


        stage('Terraform') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '4d01188a-f5c7-49ad-bc45-730090499e04']]) {
                        // Initialize and Apply Terraform Configuration
                        sh "cd terraform && terraform init"
                        sh "cd terraform && terraform apply -auto-approve"
                    }
                }
            }
        }


        stage('Push to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '4d01188a-f5c7-49ad-bc45-730090499e04']]) {
                        // Authenticate to ECR
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com"

                        // Tag the Docker image
                        sh "docker tag ${DOCKER_IMAGE}:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/recruiters:latest"

                        // Push the Docker image to ECR
                        sh "docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/recruiters:latest"
                    }
                }
            }
        }
    }
}