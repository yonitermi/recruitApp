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
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com"

                        // Tag the Docker image
                        sh "docker tag ${DOCKER_IMAGE}:latest \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/recruiters:latest"

                        // Push the Docker image to ECR
                        sh "docker push \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/recruiters:latest"
                    }
                }
            }
        }

        stage('Deploy Argo CD to EKS') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '4d01188a-f5c7-49ad-bc45-730090499e04']]){
                        // Set up kubectl to interact with your EKS cluster
                        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name recruit-cluster"

                        // Install Argo CD
                        sh "kubectl create namespace argocd || true"
                        sh "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

                        // Wait for Argo CD to become ready
                        sh "kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=120s"

                        // Start port forwarding in the background
                        sh "kubectl port-forward svc/argocd-server -n argocd 8080:443 &"
                        sleep 30 // Wait a bit to ensure the port forwarding is established

                        // Retrieve Argo CD admin password
                        def adminPassword = sh(script: "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d", returnStdout: true).trim()

                        // Login to Argo CD using the retrieved address and admin password
                        sh "argocd login localhost:8080 --username admin --password ${adminPassword} --insecure"

                        // Create an application in Argo CD from the application.yaml
                        sh "argocd app create -f argocd/application.yaml"
                    }
                }
            }
        }
    }
}