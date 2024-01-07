pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = 'yoniyonatab/recruit'  
        IMAGE_VERSION = "1.0.${env.BUILD_NUMBER}" 
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT = "760626477714"
    }

    stages {
        
        
        stage('Checkout Code') {
            steps {
                // Use SSH URL for the repository in the checkout step
                checkout([$class: 'GitSCM', branches: [[name: '*/master']],
                        userRemoteConfigs: [[url: 'git@github.com:yonitermi/recruitApp.git', credentialsId: 'jenkins_github']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: []])

                script {
               // Synchronize with the remote repository
                sshagent(credentials: ['jenkins_github']) {
                    sh "git checkout master"
                    sh "git pull --rebase origin master"
                }

                // Read the version from version.txt
                def version = readFile('version.txt').trim()

                // Increment the patch version
                def (major, minor, patch) = version.tokenize('.')
                patch = patch.toInteger() + 1
                IMAGE_VERSION = "${major}.${minor}.${patch}"

                // Write the incremented version back to version.txt
                writeFile file: 'version.txt', text: IMAGE_VERSION

                // Update the deployment file with the new image version
                def newImage = "${DOCKER_IMAGE}:${IMAGE_VERSION}"
                sh "sed -i 's|image:.*|image: ${newImage}|' ./k8s/flaskapp-deployment.yaml"

                // Commit and push the updated files back to your repo
                sshagent(credentials: ['jenkins_github']) {
                    sh """
                        git config user.email "jenkins@yourdomain.com"
                        git config user.name "Jenkins"
                        git add version.txt ./k8s/flaskapp-deployment.yaml
                        git commit -m "Update version to ${IMAGE_VERSION} and deployment image to ${newImage}"
                        git push origin master
                    """
                    }
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                script {
                    // Build a Docker image from your Dockerfile
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_VERSION} ."
                }
            }
        }

       
        stage('Push to Docker Hub') {
            steps {
                script {
                          
                    sh "docker login -u yoniyonatab -p Retailsoft2022!"
                    sh "docker push ${DOCKER_IMAGE}:${IMAGE_VERSION}"
                    sh "docker logout"             
                     
                        }
                    }
                }

        
        /*
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
                        // in case i will push to AWS ECR_REPO = sh(script: "cd terraform && terraform output -raw ecr_repository_name", returnStdout: true).trim()
                        EKS_CLUSTER = sh(script: "cd terraform && terraform output -raw eks_cluster_name", returnStdout: true).trim()
                    }
                }
            }
        }
        
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
        } */
    }
}


        /*
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
       */