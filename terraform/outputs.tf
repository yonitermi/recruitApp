# Output for ECR Repository Name
output "ecr_repository_name" {
  value = aws_ecr_repository.recruiters.name
  description = "The name of the ECR repository"
}

# Output for EKS Cluster Name
output "eks_cluster_name" {
  value = module.eks.cluster_id
  description = "The name of the EKS cluster"
}
