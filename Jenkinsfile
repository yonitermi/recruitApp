pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = 'recruit'  // Replace with your Docker image name
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT = "760626477714"
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

                        // Fetch outputs
                        ECR_REPO = sh(script: "cd terraform && terraform output -raw ecr_repository_name", returnStdout: true).trim()
                        EKS_CLUSTER = sh(script: "cd terraform && terraform output -raw eks_cluster_name", returnStdout: true).trim()
                    }
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    // Check out the master branch explicitly
                    sh "git checkout master"

                    // Create the full ECR image URL
                    def ecrImage = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest"

                    // Change directory and replace the placeholder in the yaml file in one step
                    sh """
                    cd k8s
                    sed -i 's|REPLACE_WITH_ECR_IMAGE|${ecrImage}|' flaskapp-deployment.yaml
                    """

                    // Git configuration and commit the changes
                    sh """
                    git config user.email 'jenkins@example.com'
                    git config user.name 'Jenkins'
                    git add k8s/flaskapp-deployment.yaml
                    git commit -m 'Update ECR image URL in Kubernetes Deployment'
                    git push origin master
                    """
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
                        sh "docker tag ${DOCKER_IMAGE}:latest \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest"

                        // Push the Docker image to ECR
                        sh "docker push \$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest"
                    }
                }
            }
        }




        /*
        stage('Deploy using Argo CD ') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '4d01188a-f5c7-49ad-bc45-730090499e04']]){
                        // Set up kubectl to interact with your EKS cluster
                        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}"

                        // Install Argo CD
                        sh "kubectl create namespace argocd || true"
                        sh "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

                        // Wait for Argo CD to become ready
                        sh "kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=120s"

                        // Change the argocd-server service to LoadBalancer
                        sh "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"

                        // Wait for LoadBalancer IP to be assigned
                        echo "Waiting for LoadBalancer IP to be assigned to argocd-server service..."
                        sleep 60 // Adjust this value based on how long it typically takes to provision a LoadBalancer in your environment

                        // Retrieve Argo CD LoadBalancer IP
                        def argoCDServerAddress = sh(script: "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", returnStdout: true).trim()
                        echo "Argo CD Server Address: ${argoCDServerAddress}"

                        // Retrieve Argo CD admin password
                        def adminPassword = sh(script: "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d", returnStdout: true).trim()

                        // Login to Argo CD using the LoadBalancer IP and admin password
                        sh "argocd login ${argoCDServerAddress} --username admin --password ${adminPassword} --insecure | echo y"

                        // Create an application in Argo CD from the application.yaml
                        sh "argocd app create -f argocd/application.yaml"
                    }
                }
            }
        }
        */
    }
}